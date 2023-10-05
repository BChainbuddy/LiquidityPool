# Liquidity pool

This is a liquidity pool made by me. It has a lot of functionalities. The owner can set whatever tokens they want to include in the pool. The users can then exchange tokens in the liquidity pool. The users also get a permission to add liquidity tokens. The tokens represent how much of a liquidity pool a certain user owns. The yield is the distributed to the liquidity providers. They can withdraw tokens daily. The owner needs to lock the initial liquidity for 365 days so the liquidity pool stays secure for one year.

## This project is made with hardhat. The deploy command is:

yarn hardhat deploy

## This command deploys both the custom token and the liquidity pool.

## To deploy only token:

yarn hardhat deploy --tags token

## To deploy only liquidity pool(change the token addresses in 02-deploy-LiquidityPool.js):

yarn hardhat deploy --tags liquiditypool
