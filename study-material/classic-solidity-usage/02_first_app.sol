/* 
First Application
    Here is a simple contract that you can get, increment and decrement the count store in this contract.
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Counter {
    uint256 public count;

    // function to get the current count
    function get() public view returns (uint256) {
        return count;
    }

    // function increment count by 1
    function inc() public {
        count += 1;
    }

    // function decrement count by 1
    function dec() public {
        count -= 1;
    }
}
