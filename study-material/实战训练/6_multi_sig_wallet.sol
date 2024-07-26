// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
多签钱包的功能: 合约有多个 owner，一笔交易发出后，需要多个 owner 确认，确认数达到最低要求数之后，才可以真正的执行。

原理
    部署时候传入地址参数和需要的签名数
        多个 owner 地址
        发起交易的最低签名数
    有接受 ETH 主币的方法，
    除了存款外，其他所有方法都需要 owner 地址才可以触发
    发送前需要检测是否获得了足够的签名数
    使用发出的交易数量值作为签名的凭据 ID（类似上么）
    每次修改状态变量都需要抛出事件
    允许批准的交易，在没有真正执行前取消。
    足够数量的 approve 后，才允许真正执行。
*/

contract MultiSigWallet {
    // 多个owner
    address[] private owners;
    mapping(address => bool) private isOwner;
    uint256 private immutable min;
    mapping(uint256 => mapping(address => bool)) public approved;
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool exected;
    }
    Transaction[] private transactions;

    constructor(address[] memory _owners, uint256 _min) {
        require(
            _owners.length >= 1 && _min >= 1 && _min <= _owners.length,
            "invalid params"
        );
        for (uint256 index = 0; index < _owners.length; index++) {
            address owner = _owners[index];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner is not unique"); // 如果重复会抛出错误
            isOwner[owner] = true;
        }
        owners = _owners;
        min = _min;
    }

    receive() external payable {}

    fallback() external payable {}

    modifier onlyOwner() {
        require(isOwner[msg.sender], "only owner allowed");
        _;
    }

    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "tx doesn't exist");
        _;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function submit(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwner {
        transactions.push(
            Transaction({to: _to, value: _value, data: _data, exected: false})
        );
    }

    function approv(uint256 _txId)
        external
        onlyOwner
        txExists(_txId)
    {
        approved[_txId][msg.sender] = true;
    }

    function execute(uint256 _txId)
        external
        onlyOwner
    {
        require(getApprovalCount(_txId) >= min, "not enough approval");
        Transaction storage transaction = transactions[_txId];
        transaction.exected = true;
        (bool sucess, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(sucess, "tx failed");
    }

    function getApprovalCount(uint256 _txId)
        public
        view
        returns (uint256 count)
    {
        for (uint256 index = 0; index < owners.length; index++) {
            if (approved[_txId][owners[index]]) {
                count += 1;
            }
        }
    }

    function revoke(uint256 _txId)
        external
        onlyOwner
    {
        require(approved[_txId][msg.sender], "tx not approved");
        approved[_txId][msg.sender] = false;
    }
}
