const { developmentChains } = require("../helper-hardhat-config")
const { network, getNamedAccounts, deployments } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async () => {
    const { deployer } = await getNamedAccounts()
    const { deploy, log } = deployments

    log("Getting the addresses of tokens and buying them...")
    //GET THE TOKENS AND ADDRESS(USDC, SIMPLETOKEN, AMOUNTUSDC, AMOUNT SIMPLETOKEN)
    const simpleToken = await ethers.getContract("SimpleToken", deployer)
    const simpleTokenAddress = simpleToken.target
    const usdcAddress = "0x746d7b1dfcD1Cc2f4b7d09F3F1B9A21764FBeB33" //SEPOLIA
    //GET THE USDC TOKEN

    const blockConfirmations = developmentChains.includes(network.name) ? 0 : 6
    log("Deploying...")
    const liquidityPool = await deploy("LiquidityPool", {
        log: true,
        from: deployer,
        waitConfirmations: blockConfirmations,
        args: args,
    })
    log("Deployed!!!")

    log("Verifying...")
    if (process.env.ETHERSCAN_API_KEY && !developmentChains.includes(network.name)) {
        await verify(liquidityPool.target, args)
    }
}
