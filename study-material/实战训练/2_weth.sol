// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
WETH 是包装 ETH 主币，作为 ERC20 的合约。 标准的 ERC20 合约包括如下几个
    3 个查询
        balanceOf: 查询指定地址的 Token 数量
        allowance: 查询指定地址对另外一个地址的剩余授权额度
        totalSupply: 查询当前合约的 Token 总量
    2 个交易
        transfer: 从当前调用者地址发送指定数量的 Token 到指定地址。
            这是一个写入方法，所以还会抛出一个 Transfer 事件。
        transferFrom: 当向另外一个合约地址存款时，对方合约必须调用 transferFrom 才可以把 Token 拿到它自己的合约中。
    2 个事件
        Transfer
        Approval
    1 个授权
        approve: 授权指定地址可以操作调用者的最大 Token 数量。
*/

contract WETH {
    string public constant coinName = "WETH COIN";
    string public constant symbol = "WETH";
    address public immutable owner;
    mapping(address => uint256) public balance;
    mapping(address => mapping(address => uint256)) public allowanced;
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed from, address indexed to, uint256 amount);

    // constructor() {

    // }

    function mustHave(address _user, uint256 _amount) internal view {
        require(balance[_user] > _amount, "not enough balance");
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balance[_user];
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256) {
        return allowanced[_owner][_spender];
    }

    function transfer(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        return transferFrom(_from, _to, _amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        mustHave(_from, _amount);
        if (msg.sender != _from) {
            require(
                allowanced[_from][msg.sender] >= _amount,
                "not enough authority balance"
            );
            allowanced[_from][msg.sender] -= _amount;
        }
        balance[_from] -= _amount;
        balance[_to] += _amount;
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approval(address _to, uint256 _amount) public returns (bool) {
        allowanced[msg.sender][_to] = _amount;
        emit Approval(msg.sender, _to, _amount);
        return true;
    }
}
