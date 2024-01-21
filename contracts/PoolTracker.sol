// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./LiquidityPool.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

error PoolTracker_noTokensDetected();
error PoolTracker_pairAlreadyExists();

// To do:
// Timer: if the owner doesnt deploy initial liquidity in one day the
// liquidity pool gets untracked, is not part of platform anymore
contract PoolTracker {
    // Tracker for created pools, will add to database
    event poolCreated(LiquidityPool pool, address assetOne, address assetTwo);

    // Mapping of pool Paris, to store existing ones
    mapping(address => address) public poolPairs;

    // Mapping of pool per Owner
    mapping(address => LiquidityPool[]) public poolOwner;

    // Pool creator, approve enough for two transferfroms(one to contract(by msg sender) and one from contract(by contract))
    function createPool(
        address _assetOneAddress,
        address _assetTwoAddress,
        uint256 amountOne,
        uint256 amountTwo
    ) external {
        if (
            poolPairs[_assetOneAddress] == _assetTwoAddress ||
            poolPairs[_assetTwoAddress] == _assetOneAddress
        ) // To prevent duplicate pools
        {
            revert PoolTracker_pairAlreadyExists();
        }
        // Transfer of tokens
        IERC20(_assetOneAddress).transferFrom(msg.sender, address(this), amountOne);
        IERC20(_assetTwoAddress).transferFrom(msg.sender, address(this), amountTwo);
        // Creation of pool
        LiquidityPool poolAddress = new LiquidityPool(_assetOneAddress, _assetTwoAddress);
        // Approve
        IERC20(_assetOneAddress).approve(address(poolAddress), amountOne);
        IERC20(_assetTwoAddress).approve(address(poolAddress), amountTwo);
        // Add initial liquidity
        poolAddress.addInitialLiquidity(amountOne, amountTwo);
        // Update mappings
        poolOwner[msg.sender].push(poolAddress);
        poolPairs[_assetOneAddress] = _assetTwoAddress;
        // Emit the event
        emit poolCreated(poolAddress, _assetOneAddress, _assetTwoAddress);
    }
}
