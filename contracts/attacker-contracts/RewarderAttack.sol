// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../DamnValuableToken.sol";


interface IPool {
    function flashLoan(uint256 amount) external;
}

contract RewarderAttack {

    using Address for address;

    address private owner;
    IPool private pool;

    constructor(address poolAddress) {
        pool = IPool(poolAddress);
        owner = msg.sender;
    }

    function requestFlashLoan(uint256 amount) external {
        pool.flashLoan(amount);
    }


    function receiveFlashLoan(uint256 amount) external {
        // code exploit here

    }

}