const { getNamedAccounts, deploymetns, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { assert, expect } = require("chai")

describe("Pool tracker test", () => {
    let poolTracker, deployer, token1, token2, mintAmount, approveAmount
    beforeEach(async () => {
        mintAmount = ethers.parseEther("1000")
        approveAmount = ethers.parseEther("5000")
        await deployments.fixture(["all"])
        deployer = (await getNamedAccounts()).deployer
        token1 = await ethers.getContract("SimpleToken", deployer)
        token2 = await ethers.getContract("SampleToken", deployer)
        poolTracker = await ethers.getContract("PoolTracker", deployer)
    })
    describe("Creates a pool", () => {
        it("adds Pool to mapping", async () => {
            await token1.approve(poolTracker.target, approveAmount)
            await token2.approve(poolTracker.target, approveAmount)
            await poolTracker.createPool(token1.target, token2.target, mintAmount, mintAmount)
            const array = await poolTracker.poolOwner(deployer, 0)
            expect(array).to.not.equal(undefined)
            await expect(poolTracker.poolOwner(deployer, 1)).to.be.reverted
        })
        it("emits the event", async () => {
            await token1.approve(poolTracker.target, approveAmount)
            await token2.approve(poolTracker.target, approveAmount)
            const transaction = await poolTracker.createPool(
                token1.target,
                token2.target,
                mintAmount,
                mintAmount
            )
            const txReceipt = await transaction.wait(1)
            const array = await poolTracker.poolOwner(deployer, 0)
            expect(txReceipt.logs[11].args.pool).to.equal(array)
            expect(txReceipt.logs[11].args.assetOne).to.equal(token1.target)
            expect(txReceipt.logs[11].args.assetTwo).to.equal(token2.target)
        })
        it("Enables liquidity Pool functionalities", async () => {
            await token1.approve(poolTracker.target, approveAmount)
            await token2.approve(poolTracker.target, approveAmount)
            const transaction = await poolTracker.createPool(
                token1.target,
                token2.target,
                mintAmount,
                mintAmount
            )
            const txReceipt = await transaction.wait(1)
            const poolAddress = txReceipt.logs[11].args.pool
            const poolContract = await ethers.getContractAt("LiquidityPool", poolAddress)
            expect(await poolContract.assetOneAddress()).to.equal(token1.target)
            expect(await poolContract.assetTwoAddress()).to.equal(token2.target)
        })
        it("Sets the deployer as the owner of the liquidity pool", async () => {
            await token1.approve(poolTracker.target, approveAmount)
            await token2.approve(poolTracker.target, approveAmount)
            const transaction = await poolTracker.createPool(
                token1.target,
                token2.target,
                mintAmount,
                mintAmount
            )
            const txReceipt = await transaction.wait(1)
            const poolAddress = txReceipt.logs[11].args.pool
            const poolContract = await ethers.getContractAt("LiquidityPool", poolAddress)
            expect(await poolContract.owner()).to.equal(poolTracker.target)
        })
        it("Sets the pool pair", async () => {
            await token1.approve(poolTracker.target, approveAmount)
            await token2.approve(poolTracker.target, approveAmount)
            const transaction = await poolTracker.createPool(
                token1.target,
                token2.target,
                mintAmount,
                mintAmount
            )
            await transaction.wait(1)
            expect(await poolTracker.poolPairs(token1.target)).to.equal(token2.target)
        })
        it("Revert if pool pair exists", async () => {
            await token1.approve(poolTracker.target, approveAmount)
            await token2.approve(poolTracker.target, approveAmount)
            const transaction = await poolTracker.createPool(
                token1.target,
                token2.target,
                mintAmount,
                mintAmount
            )
            await transaction.wait(1)
            await expect(
                poolTracker.createPool(token1.target, token2.target, mintAmount, mintAmount)
            ).to.be.reverted
            await expect(
                poolTracker.createPool(token2.target, token1.target, mintAmount, mintAmount)
            ).to.be.reverted
        })
    })
})
