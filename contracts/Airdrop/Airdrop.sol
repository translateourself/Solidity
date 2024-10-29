// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC20.sol";

//  空投合约向多个地址转账
contract Airdrop {
    mapping(address => uint) failTransferList;
    //  当前合约airdrop向外转账先获得msg.sender授权
    //  _token 转账的ERC20地址 
    //  _address 空投地址数组
    //  _amouont 代币数量数组（每个地址的空投币数量）
    function multiTransferToken (
    address _token,
    address[] calldata _addresses,
    uint256[] calldata _amounts
    ) external 
     {
        //  首先检查_address和_amounts 的数组长度
        require(
            _addresses.length == _amounts.length,
        "Lengths of Addresses And Account  Not EQUAL"
        );
        
        IERC20 token = IERC20(_token);//  以_token为地址创建 IERC20对象
        uint _amountsSum = getSum(_amounts);//  计算总共要空投的代币数量
        require(token.allowance(msg.sender, address(this)) >= _amountsSum,
        "The Allowance Is NOT Enough"
        );
        for (uint8 i; i < _addresses.length;i++) {
            token.transferFrom(msg.sender, _addresses[i], _amounts[i]);

        }
    
    }
    function getSum(uint256[] calldata _arr) public pure returns (uint sum) {
        for (uint i = 0; i < _arr.length; i++) {
            sum += _arr[i];
    }
    }
}

contract ERC20 is IERC20 {

    mapping(address => uint256) public override balanceOf;

    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public override totalSupply;   // 代币总供给

    string public name;   // 名称
    string public symbol;  // 符号
    
    uint8 public decimals = 18; // 小数位数

    // @dev 在合约部署的时候实现合约名称和符号
    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    }

    // @dev 实现`transfer`函数，代币转账逻辑
    function transfer(address recipient, uint amount) public override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // @dev 实现 `approve` 函数, 代币授权逻辑
    function approve(address spender, uint amount) public override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // @dev 实现`transferFrom`函数，代币授权转账逻辑
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // @dev 铸造代币，从 `0` 地址转账给 调用者地址
    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // @dev 销毁代币，从 调用者地址 转账给  `0` 地址
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

}