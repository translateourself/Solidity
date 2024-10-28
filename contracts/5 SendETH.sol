// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

error SendFailed();
error CallFailed();
contract SendETH {
    // 合约contract里其实没有ETH 需要通过系统给其send 故而在构造函数时候需要写入接受
    constructor() payable {}
    receive() external payable{}

    // use the transfer to send ETH
    function transferETH(address payable  _to, uint256 amount) external payable {
        _to.transfer(amount);
    }

    // use the send method to send ETH
    function sendETH(address payable _to, uint256 amount) external payable {
        //  deal the send failed return value, if failed ,revert transection and error.
        bool success = _to.send(amount);
        if (!success) {
            revert SendFailed();
        }
    }
    // use the call to send eth
    function callETH(address payable _to, uint256 amount) external  payable {
        (bool success,) = _to.call{value:amount}("");
        if (!success) {
            revert CallFailed();
            
        }
    }

}
contract ReceiveETH {
    //  declare receive eth is a event that can record amount and gas
    event Log(uint amount, uint gas);
    
    //  receive fuction will work when receive the eth 
    receive() external payable {
        emit Log(msg.value , gasleft());
    } 

    //  return the eth balance of the contract
    function getBalance() view public returns(uint) {
        return address(this).balance;
    }
    
} 