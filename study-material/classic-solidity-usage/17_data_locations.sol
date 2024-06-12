/*
Data Locations - Storage, Memory and Calldata
Variables are declared as either storage, memory or calldata to explicitly specify the location of the data.

storage variable is a state variable (store on blockchain)
memory variable is in memory and it exists while a function is being called
calldata special data location that contains function arguments
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract DataLocations {
    uint256[] public arr;
    mapping(uint256 => address) map;

    struct MyStruct {
        uint256 foo;
    }

    mapping(uint256 => MyStruct) myStructs;

    function _f(
        uint256[] storage _arr,
        mapping(uint256 => address) storage _map,
        MyStruct storage _myStruct
    ) internal {
        // do something here
    }

    // You can return memory variables
    function g(uint256[] memory _arr) public returns (uint256[] memory) {
        // do something with memory array
    }

    function h(uint256[] calldata _arr) external {
        // do something with calldata array
    }
}
