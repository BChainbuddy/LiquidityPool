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

    // Pool creator
    function createPool(address _assetOneAddress, address _assetTwoAddress) external {
        if (
            poolPairs[_assetOneAddress] == _assetTwoAddress ||
            poolPairs[_assetTwoAddress] == _assetOneAddress
        ) // To prevent duplicate pools
        {
            revert PoolTracker_pairAlreadyExists();
        }
        if (
            IERC20(_assetOneAddress).balanceOf(msg.sender) < 100000000000 ||
            IERC20(_assetOneAddress).balanceOf(msg.sender) < 100000000000
        ) // To prevent creation of pool if owner doesnt have tokens
        {
            revert PoolTracker_noTokensDetected();
        }
        LiquidityPool poolAddress = new LiquidityPool(_assetOneAddress, _assetTwoAddress);
        poolPairs[_assetOneAddress] = _assetTwoAddress;
        emit poolCreated(poolAddress, _assetOneAddress, _assetTwoAddress);
    }
}
