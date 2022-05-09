// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IStrategy {
    // return the information link of this strategy
    function strategyURI() external returns (string memory);

    // return the address of the investing token
    function currency() external returns (address);

    // return if an address is allowed to invest
    // return 1 for address(0x0) if it's open to all
    function allowed(address) external returns (bool);

    // should check if msg.sender is the pool
    function init(uint256 strategyId) external;

    // return management fee in basis point (0.0001 or 0.01%)
    // for example, returning 100 means the fee is 1%
    function fee() external returns (uint256);

    // return total value of the strategy
    function totalValue() external returns (uint256);

    function run(address sender) external;

    function getShare(address token, uint256 amount) external returns (uint256);

    function getValue(uint256 share) external returns (address, uint256);

    function handleDeposit(address depositor, uint256 share) external;

    function handleDeposit(
        address depositor,
        address token,
        uint256 amount
    ) external;

    function handleWithdraw(address withdrawer, uint256 share) external;
}
