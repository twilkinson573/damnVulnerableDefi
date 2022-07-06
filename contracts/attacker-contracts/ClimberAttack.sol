// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/RewardToken.sol";
import "../the-rewarder/AccountingToken.sol";
import "../DamnValuableToken.sol";

interface ITimelock {
    function execute(address[] calldata targets, uint256[] calldata values, bytes[] calldata dataElements, bytes32 salt) external payable;
    function updateDelay(uint64 newDelay) external;

}

contract ClimberAttack {

    ITimelock timelock;

    address owner;

    constructor(
        address _timelockAddress
    ) {
        owner = msg.sender;
        timelock = ITimelock(_timelockAddress);
    }

    function triggerAttack() external {
        require(msg.sender == owner, "Only owner allowed");
        timelock.updateDelay(10);
    }

}