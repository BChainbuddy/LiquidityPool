# Liquidity Pool

Welcome to the Liquidity Pool project, a decentralized liquidity pool designed to facilitate token exchange, liquidity provision, and yield farming. This project brings together key functionalities that empower both the owner and users to participate in a robust decentralized financial ecosystem.

## Core Concepts

### 1. Liquidity Provision

Liquidity providers can add tokens to the pool, earning LP (Liquidity Provider) tokens in return. These tokens represent the share of the liquidity pool that a user owns. The more tokens provided, the larger the share.

### 2. Token Exchange

Users can swap tokens within the liquidity pool, taking advantage of the automated market maker (AMM) mechanism. The exchange rates are determined by the current balances of the two tokens in the pool, allowing for seamless and decentralized token swaps.

### 3. Yield Farming

Liquidity providers are rewarded with yield, distributed periodically. Users can claim their yield daily, adding an additional incentive for providing liquidity to the pool.

### 4. Initial Liquidity Lock

To ensure the security and stability of the liquidity pool, the owner is required to lock the initial liquidity for 365 days. This time lock mechanism provides confidence to users and stakeholders, knowing that the liquidity pool is secured for an extended period.

## Core Functions

### 1. Add Initial Liquidity

The owner can add initial liquidity to the pool by providing a specified amount of both assets.

### 2. Add Additional Liquidity

Users can add more liquidity to the pool by providing one asset, and the contract calculates the required amount of the second asset based on the current ratio.

### 3. Remove Liquidity

Users can withdraw a percentage of their liquidity, receiving back the proportional amounts of both assets.

### 4. Sell Asset One

Users can sell the first asset and receive the second asset in return, with a swap fee applied.

### 5. Sell Asset Two

Users can sell the second asset and receive the first asset in return, with a swap fee applied.

### 6. Change Swap Fee

The owner can change the swap fee percentage.

### 7. Claim Yield

Users can claim their daily yield, subject to a time lock. Yield can be claimed once a day.

### 8. Time Lock Functionality

The Liquidity Pool includes time-lock functionality to secure the initial liquidity for 365 days. Certain operations, such as withdrawing initial liquidity, are restricted until the time lock expires.

## Technologies Used

-   Hardhat
-   JavaScript
-   Solidity

## Deployment

To deploy the Liquidity Pool project, use the following Hardhat deploy command:

```shell
yarn hardhat deploy
```

To deploy only the token, use:

```shell
yarn hardhat deploy --tags token
```

To deploy only the liquidity pool (change the token addresses in 02-deploy-LiquidityPool.js):

```shell
yarn hardhat deploy --tags liquiditypool
```

## Contribution

We welcome contributions from the community. If you'd like to contribute, please follow these guidelines:

1. Fork the repository.
2. Create a branch: `git checkout -b feature/your-feature-name`.
3. Commit your changes: `git commit -am 'Add some feature'`.
4. Push to the branch: `git push origin feature/your-feature-name`.
5. Submit a pull request.

Please make sure to update tests as appropriate and adhere to the code of conduct.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
