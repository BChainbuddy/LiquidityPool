# Liquidity Pool

This is a liquidity pool made by me. It has a lot of functionalities. The owner can set whatever tokens they want to include in the pool. The users can then exchange tokens in the liquidity pool. The users also get permission to add liquidity tokens. The tokens represent how much of a liquidity pool a certain user owns. The yield is then distributed to the liquidity providers, and they can withdraw tokens daily. The owner needs to lock the initial liquidity for 365 days so the liquidity pool stays secure for one year.

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
