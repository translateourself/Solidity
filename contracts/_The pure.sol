// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21 ;

contract FuctionType{
    uint256 number = 5;
    function addPure(uint256 _number) external pure returns  (uint256 new_number) {
// pure: not to see or not to write
    new_number = _number + 1;


}
// view : just to see not to write
    function addView() external view returns (uint256 new_number) {
     new_number = number + 1 ;
}    

// internal  
    function minus() internal {
        number = number - 1;
    }
//  external the function could call the internal function
    function minusCall() external {
        minus();
    }
//  external payable:  payable money
    function minusPayable() external payable returns  (uint256 balance) {
        minus();
        balance = address(this).balance;
    }
}



