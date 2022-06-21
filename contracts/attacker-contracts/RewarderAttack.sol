// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/RewardToken.sol";
import "../the-rewarder/AccountingToken.sol";
import "../DamnValuableToken.sol";

contract RewarderAttack {

    using Address for address;

    FlashLoanerPool flashLoanerPool;
    TheRewarderPool theRewarderPool;
    DamnValuableToken damnValuableToken;
    RewardToken rewardToken;

    address owner;

    constructor(
        FlashLoanerPool _flashLoanerPoolAddress, 
        TheRewarderPool _theRewarderPoolAddress, 
        DamnValuableToken _damnValuableTokenAddress, 
        RewardToken _rewardTokenAddress
    ) {
        owner = msg.sender;
        damnValuableToken = DamnValuableToken(_damnValuableTokenAddress);
        flashLoanerPool = FlashLoanerPool(_flashLoanerPoolAddress);
        theRewarderPool = TheRewarderPool(_theRewarderPoolAddress);
        rewardToken = RewardToken(_rewardTokenAddress);
    }

    function requestFlashLoan() external {
        uint256 poolBalance = damnValuableToken.balanceOf(address(flashLoanerPool));
        flashLoanerPool.flashLoan(poolBalance);
    }


    function receiveFlashLoan(uint256 amount) external {
        // code exploit here
        damnValuableToken.transfer(address(flashLoanerPool), amount);

    }

}