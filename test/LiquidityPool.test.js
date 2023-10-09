const { developmentChains } = require("../helper-hardhat-config")
const { network, getNamedAccounts } = require("hardhat")
const { assert, expect } = require("chai")

describe("LiquidityPoolTest", () => {
    let deployer, simpleToken, sampleToken, liquidityPool, user
    beforeEach("", async () => {
        deployer = (await getNamedAccounts()).deployer
        const accounts = ethers.getSigners()
        user = accounts[1]
        await deployments.fixture(["all"])
        simpleToken = await ethers.getContract("SimpleToken", deployer)
        sampleToken = await ethers.getContract("SampleToken", deployer)
        liquidityPool = await ethers.getContract("LiquidityPool", deployer)
    })
    it("Mints the tokens", async () => {
        const deployerBalanceToken1 = await simpleToken.balanceOf(deployer)
        const deployerBalanceToken2 = await sampleToken.balanceOf(deployer)
        const mintAmount = ethers.parseEther("1000")
        assert.equal(deployerBalanceToken1, mintAmount)
        assert.equal(deployerBalanceToken2, mintAmount)
    })
})
