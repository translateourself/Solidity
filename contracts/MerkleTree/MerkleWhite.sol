// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "../DutchAuction/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract  MerkleTree is ERC721 {
    bytes32 immutable public root; 
    mapping(address => bool) public mintedAddress;
    constructor(string memory name, string memory symbol, bytes32 merkleroot) 
    ERC721(name,symbol)
    {
        root = merkleroot;
    }
    function mint(address account, uint256 tokenId, bytes32[] calldata proof)
    external  {
        require(_verify(_leaf(account), proof),"Invalid merkle proof");
        require(!mintedAddress[account],"Already minted!");
        mintedAddress[account] = true;
        _mint(account,tokenId);
    }
    function _leaf(address account) internal pure returns (bytes32){
        return keccak256(abi.encodePacked(account));
    }
    function _verify(bytes32 leaf, bytes32[]memory proof) internal view returns(bool){
        return MerkleProof.verify(proof,root,leaf);
    }
}
