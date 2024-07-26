// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
众筹合约是一个募集资金的合约，在区块链上，我们是募集以太币，类似互联网业务的水滴筹。区块链早起的 ICO 就是类似业务。

1.需求分析
众筹合约分为两种角色：一个是受益人，一个是资助者。
    两种角色:
        受益人   beneficiary => address         => address 类型
        资助者   funders     => address:amount  => mapping 类型 或者 struct 类型
    状态变量按照众筹的业务：
        状态变量
            筹资目标数量    fundingGoal
            当前募集数量    fundingAmount
            资助者列表      funders
            资助者人数      fundersKey
需要部署时候传入的数据:
    受益人
    筹资目标数量
*/

contract CrowdFunding {
    address internal immutable beneficiary;
    uint256 internal immutable target;
    uint256 internal balance; // 余额
    bool internal complete; // 是否众筹完成
    mapping(address => uint256) internal funders;

    constructor(address deployer, uint256 _target) {
        beneficiary = deployer;
        target = _target;
        complete = false;
        balance = 0;
    }

    modifier notComplete() {
        require(!complete, "already finished");
        _;
    }

    function getContribute(address _user) external view returns (uint256) {
        return funders[_user];
    }

    function contribute(uint256 _amount) external notComplete {
        balance += _amount;
        uint256 contributeAmount = _amount;
        if (balance >= target) {
            complete = true;
            uint256 more = balance - target;
            if (more > 0) {
                // 比预定目标多了, 返还多余的金额
                contributeAmount -= more;
                (bool refundSuccess, ) = (payable(msg.sender)).call{
                    value: more
                }("");
                require(refundSuccess, "return fail");
            }
            balance = 0;
            (bool success, ) = (payable(beneficiary)).call{value: target}("");
            require(success, "withdraw fail");
        }
        funders[msg.sender] += contributeAmount;
    }
}
