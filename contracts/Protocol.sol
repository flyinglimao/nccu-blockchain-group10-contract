// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Strategy.sol";

contract Protocol is Ownable {
    mapping(uint256 => uint256) public lastRun; // strategy id => last run block
    IStrategy[] public approvedStrategy;
    uint256[] public reward;
    mapping(uint256 => bool) public unapproved;
    mapping(uint256 => mapping(address => uint256)) public shares;
    mapping(uint256 => uint256) public totalShares;
    IERC20 public rewardToken;

    constructor(IERC20 rewardToken_) {
        rewardToken = rewardToken_;
    }

    function approve(IStrategy strategy, uint256 rewardPergas)
        external
        onlyOwner
    {
        uint256 id = approvedStrategy.length;
        approvedStrategy.push(strategy);
        reward.push(rewardPergas);
        strategy.init(id);
    }

    function unapprove(uint256 strategyId) external onlyOwner {
        unapproved[strategyId] = true;
    }

    function deposit(uint256 strategyId, uint256 share) external {
        require(!unapproved[strategyId], "Unapproved strategy");
        approvedStrategy[strategyId].handleDeposit(msg.sender, share);
        shares[strategyId][msg.sender] += share;
        totalShares[strategyId] += share;
    }

    function withdraw(uint256 strategyId, uint256 share) external {
        require(!unapproved[strategyId], "Unapproved strategy");
        approvedStrategy[strategyId].handleWithdraw(msg.sender, share);
        shares[strategyId][msg.sender] -= share;
        totalShares[strategyId] -= share;
    }

    function run(uint256 strategyId) external {
        require(
            lastRun[strategyId] < block.number,
            "Already run in this block"
        );
        lastRun[strategyId] = block.number;
        uint256 pregas = gasleft();

        approvedStrategy[strategyId].run(msg.sender);

        rewardToken.transfer(
            msg.sender,
            (pregas - gasleft()) * reward[strategyId]
        );
    }

    function setReward(uint256 strategyId, uint256 rewardPergas) external {
        reward[strategyId] = rewardPergas;
    }
}
