// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./LiquidityPool.sol";

contract PoolTracker {
    // Tracker for created pools, will add to database
    event poolCreated(LiquidityPool pool, address assetOne, address assetTwo);

    // Owners can access and share their liquidity pools
    mapping(address => LiquidityPool[]) public poolOwner;

    // Pool creator
    function createPool(address _assetOneAddress, address _assetTwoAddress) external {
        LiquidityPool poolAddress = new LiquidityPool(_assetOneAddress, _assetTwoAddress);
        poolOwner[msg.sender].push(poolAddress);
        emit poolCreated(poolAddress, _assetOneAddress, _assetTwoAddress);
    }
}
