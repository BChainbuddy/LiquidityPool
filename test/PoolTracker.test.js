const { getNamedAccounts, deploymetns, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { assert, expect } = require("chai")

describe("Pool tracker test", () => {
    let poolTracker, deployer, token1, token2
    beforeEach(async () => {
        await deployments.fixture(["all"])
        deployer = (await getNamedAccounts()).deployer
        token1 = await ethers.getContract("SimpleToken", deployer)
        token2 = await ethers.getContract("SampleToken", deployer)
        poolTracker = await ethers.getContract("PoolTracker", deployer)
    })
    describe("Creates a pool", () => {
        it("adds Pool to mapping", async () => {
            await poolTracker.createPool(token1.target, token2.target)
            const array = await poolTracker.poolOwner(deployer, 0)
            expect(array).to.not.equal(undefined)
            await expect(poolTracker.poolOwner(deployer, 1)).to.be.reverted
        })
        it("emits the event", async () => {
            const transaction = await poolTracker.createPool(token1.target, token2.target)
            const txReceipt = await transaction.wait(1)
            const array = await poolTracker.poolOwner(deployer, 0)
            expect(txReceipt.logs[0].args.pool).to.equal(array)
            expect(txReceipt.logs[0].args.assetOne).to.equal(token1.target)
            expect(txReceipt.logs[0].args.assetTwo).to.equal(token2.target)
        })
        it("Enables liquidity Pool functionalities", async () => {
            const transaction = await poolTracker.createPool(token1.target, token2.target)
            const txReceipt = await transaction.wait(1)
            const poolAddress = txReceipt.logs[0].args.pool
            const poolContract = await ethers.getContractAt("LiquidityPool", poolAddress)
            expect(await poolContract.assetOneAddress()).to.equal(token1.target)
            expect(await poolContract.assetTwoAddress()).to.equal(token2.target)
        })
        it("Sets the deployer as the owner of the liquidity pool", async () => {
            const transaction = await poolTracker.createPool(token1.target, token2.target)
            const txReceipt = await transaction.wait(1)
            const poolAddress = txReceipt.logs[0].args.pool
            const poolContract = await ethers.getContractAt("LiquidityPool", poolAddress)
            expect(await poolContract.owner()).to.equal(poolTracker.target)
        })
    })
})
