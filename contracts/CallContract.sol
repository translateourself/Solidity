// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract OtherContract {
    uint256 private _x = 0;// state variable
    // recording the event of receiving 
    event Log(uint amount, uint gas);

    //  return ETH balance of this Contract
    function getBalance() view public returns (uint) {
        return address(this).balance;
    }
    //  the fuction can change the state variable _x and send eth to this contract
    function setX(uint256 x) external  payable {
        _x = x;
        //  if the contract receive eth, release log event
        if (msg.value > 0) {
            emit Log(msg.value, gasleft());
        } 
    }
    //  read the x
    function getX() external view returns (uint x) {
        x = _x;
    }
}
 contract CallContract {
    function callSet(address _Address, uint256 x) external {
        OtherContract(_Address).setX(x);
    }
    function callGetX(OtherContract _Address) external view returns(uint x){
        x = _Address.getX();
    }
    function callGetX2(address _Address) external view returns (uint x) {
        OtherContract oc = OtherContract(_Address);
        x = oc.getX();
    }
    function setXTransferETH(address otherContract, uint256 x) payable external {
        OtherContract(otherContract).setX{value: msg.value}(x);
    }
 }
