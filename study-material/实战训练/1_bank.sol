// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/*
所有人都可以存钱
    ETH
只有合约 owner 才可以取钱
只要取钱，合约就销毁掉 selfdestruct
扩展：支持主币以外的资产
    ERC20
    ERC721
*/

contract Bank {
    // 状态变量
    address public immutable owner;
    // 事件
    event Save(address _user, uint256 amount);
    event SaveByFallback(address _user, uint256 amount);
    event Withdraw(uint256 amount);

    // receive
    receive() external payable {
        emit Save(msg.sender, msg.value);
    }

    fallback() external payable {
        emit SaveByFallback(msg.sender, msg.value);
    }

    // 构造函数
    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    // 取钱
    function withdraw() external onlyOwner {
        emit Withdraw(address(this).balance);
        // Cancun升级后已无法这样销毁
        // selfdestruct(payable(msg.sender));
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
