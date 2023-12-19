const { developmentChains, networkConfig } = require("../helper-hardhat-config")
const { network, getNamedAccounts, deployments, getChainId } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async () => {
    const { deployer } = await getNamedAccounts()
    const { deploy, log } = deployments

    log("Getting the addresses of tokens...")
    //GET THE TOKENS AND ADDRESSES
    const simpleToken = await ethers.getContract("SimpleToken", deployer)
    const sampleToken = await ethers.getContract("SampleToken", deployer)
    const simpleTokenAddress = simpleToken.target
    const sampleTokenAddress = sampleToken.target

    args = [simpleTokenAddress, sampleTokenAddress]

    const blockConfirmations = developmentChains.includes(network.name) ? 0 : 6
    log("Deploying...")
    const liquidityPool = await deploy("LiquidityPool", {
        log: true,
        from: deployer,
        waitConfirmations: blockConfirmations,
        args: args,
    })
    log("Deployed!!!")

    if (process.env.ETHERSCAN_API_KEY && !developmentChains.includes(network.name)) {
        log("Verifying...")
        await verify(liquidityPool.address, args)
    }
}

module.exports.tags = ["all", "liquidityPool", "pool"]
