// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../DutchAuction/IERC721.sol";
import "../DutchAuction/IERC721Receiver.sol";
import "../DutchAuction/WTFApe.sol";


contract NFTwap is IERC721Receiver {
    event List(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    event Purchase(
        address indexed buyer,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    event Revoke(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId
    );
    event Update(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 newPrice
    );
    // 定义order订单类
    struct Order {
        address owner;
        uint256 price;
    }
    //  NFT order映射
    mapping(address => mapping(uint256 => Order)) public nftList;

    fallback() external payable { } 

    // 挂单：卖家上架NFT,合约地址为_nftaddr.tokenId为_tokenId,价格_price为以太币ETH
    function list(address _nftAddr,uint256 _tokenId,uint256 _price) public {
        // 创建IERC721合约类对象
        IERC721 _nft = IERC721(_nftAddr);
        // 通过tokenID获取nft币的授权地址 是否为当前合约
        require(_nft.getApproved(_tokenId) == address(this),"Need Approve"); 
        require(_price > 0);
        //创建一个Order类对象用这个对象内设定_nftaddress and tokenID
        Order storage _order = nftList[_nftAddr][_tokenId];
       _order.owner = msg.sender;
       _order.price = _price;
       _nft.safeTransferFrom(msg.sender, address(this),_tokenId);
       emit List(msg.sender, _nftAddr, _tokenId, _price);
    }
    //  买家买NFT
    function purchase( address _nftAddr, uint256 _tokenId) public payable {
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.price > 0);
        require(msg.value >= _order.price,"Increase price");
        //  将NFT转账到合约
        IERC721 _nft = IERC721(_nftAddr);
        //NFT转出给买家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        // 将ETH转给卖家
        payable(_order.owner).transfer(_order.price);
        //  将多余的ETH退回给买家
        payable (msg.sender).transfer(msg.value - _order.price);
        
        delete nftList[_nftAddr][_tokenId]; //删除order
        // emit purchase 事件
        emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price);

    }
    // 卖家撤销挂单
    function revoke(address _nftAddr, uint256 _tokenId) public {
        Order storage _order =nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender,"Not Owner");
        // 创建_nft对象
        IERC721 _nft = IERC721(_nftAddr);
        //  确定NFT在合约中
        require((_nft.ownerOf(_tokenId) == address(this)),"NFT is not here");
        // 将NFT转给买家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete  nftList[_nftAddr][_tokenId];
        emit Revoke(msg.sender, _nftAddr, _tokenId);

    }

    // 调整价格
    function update(address _nftAddr,uint256 _tokenId, uint256 _newPrice) public {
        require(_newPrice > 0,"Invalid Prince");// nft 价格大于0
        Order storage _order = nftList[_nftAddr][_tokenId];
        require(_order.owner == msg.sender,"Not Owner");
        IERC721 _nft = IERC721(_nftAddr);
        require((_nft.ownerOf(_tokenId) == address(this)) ,"NFT is not here");
        // 调整_NFT的价格
        _order.price = _newPrice;

        //  释放update事件
        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);

    }

    //

    //  implement IERC721rReceived 函数接收代币
    function onERC721Received (
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
     ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}