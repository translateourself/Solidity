// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC721.sol";

contract DutchAuction is Ownable, ERC721 {
    uint256 public constant COLLECTION_SIZE = 10000;
    uint256 public  constant AUCTION_START_PRICE = 1 ether;
    uint256 public  constant AUCTION_END_PRICE = 0.1 ether;
    uint256 public  constant AUCTION_TIME = 10 minutes;
    uint256 public  constant AUCTION_DROP_INTERVAL = 1 minutes;//  衰减时间
    uint256 public  constant AUCTION_DROP_PER_STEP = 
        (AUCTION_START_PRICE - AUCTION_END_PRICE )/
        (AUCTION_TIME / AUCTION_DROP_INTERVAL); //  每次衰减的步长

    uint256 public  auctionStartTime;  //  拍卖开始时间戳
    string private _baseTokenURI;  //  METAdata URI
    uint256[] private _allTokens;  //  记录所有tokenID

    //  拍卖开始时间： 我们在构造函数中声明当前区块时间为起始时间
    constructor() Ownable (msg.sender) ERC721("My Dutch Auction","My Dutch Auction"){
        auctionStartTime = block.timestamp;
    }   
    
    function totalSupply() public view virtual returns (uint256) {
        return _allTokens.length;
    }

    //  在_allTokens 中添加一个新的token
    function _addTokenToAllTakensEnumeration(uint256 tokenId) private {
        _allTokens.push(tokenId);
    }
// 拍卖函数
    function  auctionMint(uint256 quantity) external payable {
        uint256 _saleStartTime = uint256(auctionStartTime);
        //  检查是否设置起拍时间，拍卖是否开始
        require(
            _saleStartTime != 0 && block.timestamp >= _saleStartTime,
            "sale has not start yet"
        );
        //  
        require(
            totalSupply() + quantity <= COLLECTION_SIZE,
            "Not enough remaining reserved for auction to support desired mint amout" 
        );
        //  检查用户是否支付足够ETH
        uint256 totalCost = getAuctionPrice() * quantity;
        require(msg.value >= totalCost,"Need to send more ETH");

        //  铸币Mint NFT
        for (uint256 i = 0; i < quantity; i++) {
            uint256 minIndex = totalSupply();
            _mint(msg.sender, minIndex);
            _addTokenToAllTakensEnumeration(minIndex);
        }
        //  退回多余的拍卖价格
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }
    //  获得拍卖实时价格
    function getAuctionPrice()
    public view returns (uint256)
    {
        if (block.timestamp < auctionStartTime){
            return AUCTION_START_PRICE;
        }else if (block.timestamp - auctionStartTime >= AUCTION_TIME){
            return AUCTION_END_PRICE;
        }else{
            uint256 steps = (block.timestamp - auctionStartTime) / AUCTION_DROP_INTERVAL;
            return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }
    function setAuctionStartTime(uint32 timestamp) external onlyOwner {
        auctionStartTime = timestamp;
    }

    //  BaseUrI
    function _baseURI() internal view virtual override  returns (string memory) {
        return _baseTokenURI;
    }
    //  Setter function only Owner
    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }
    //  
    function wihtdrawMoney() external onlyOwner(){
        (bool success,) = msg.sender.call{value:address(this).balance}("");
    }
    
}