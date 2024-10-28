// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract DataChange{
    //  the data location of x is storage
    //  tHIS is the only place where the data location can't be changing.
    uint[] x = [1,2,3];
    function fStorage() public {
        //  declaration a variable called Xstorage which is storage toward x
        // when I change Xstorage, the x can be influenced.
        uint[] storage Xstorage = x;
        Xstorage[0] = 100;
    }
    function fMemory() public  view {
        //  declare a memeory variable, toward x. when I change xMemory, the x isn't influenced
        uint[] memory xMemory = x;
        xMemory[0] = 101;
    }
    function fCalldata(uint[] calldata _x) public pure returns(uint[] calldata){
        
        return (_x);
    }
    
}
