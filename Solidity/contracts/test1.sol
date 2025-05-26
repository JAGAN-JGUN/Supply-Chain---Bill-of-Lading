//SPDX-License-Identifier: MIT

pragma solidity >=0.4.0 <=0.9.0;

contract Test1 {
    string public Str;
    constructor() public {
        Str = "Unknown";
    }
    
    function setString(string memory nm) public{
        Str = nm ;
    }

    function getString() public view returns(string memory){
        return Str;
    }
}