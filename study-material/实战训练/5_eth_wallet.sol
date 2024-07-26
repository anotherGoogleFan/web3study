// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
这一个实战主要是加深大家对 3 个取钱方法的使用
    任何人都可以发送金额到合约
    只有 owner 可以取款
    3 种取钱方式
*/
contract EthWallet {
    address payable private immutable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    modifier ownerWithdraw() {
        require(msg.sender == owner, "only owner allowed");
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    function getBalance() external view returns(uint256){
        return address(this).balance;
    }

    function withdrawByCall(uint256 _amount) external ownerWithdraw {
        require(address(this).balance >= _amount, "not enough balance");
        (bool success, ) = owner.call{value: _amount}("");
        require(success, "withdraw fail");
    }

    function withdrawByTransfer(uint256 _amount) external ownerWithdraw {
        require(address(this).balance >= _amount, "not enough balance");
        owner.transfer(_amount);
    }

    function withdrawBySend(uint256 _amount) external ownerWithdraw {
        require(address(this).balance >= _amount, "not enough balance");
        bool success = owner.send(_amount);
        require(success, "withdraw fail");
    }
}
