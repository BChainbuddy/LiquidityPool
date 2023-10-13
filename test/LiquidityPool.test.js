const { developmentChains } = require("../helper-hardhat-config")
const { network, getNamedAccounts } = require("hardhat")
const { assert, expect } = require("chai")
const { moveTime } = require("../utils/move-time")
const { days } = require("@nomicfoundation/hardhat-network-helpers/dist/src/helpers/time/duration")

describe("LiquidityPoolTest", () => {
    let deployer, simpleToken, sampleToken, liquidityPool, user, mintAmount
    beforeEach("", async () => {
        //GET THE ACCOUNTS AND SET VARIABLES
        mintAmount = ethers.parseEther("1000")
        deployer = (await getNamedAccounts()).deployer
        const accounts = ethers.getSigners()
        user = accounts[1]
        await deployments.fixture(["all"])

        //GET THE CONTRACTS
        simpleToken = await ethers.getContract("SimpleToken", deployer)
        sampleToken = await ethers.getContract("SampleToken", deployer)
        liquidityPool = await ethers.getContract("LiquidityPool", deployer)
    })
    describe("Token part", () => {
        it("Mints the tokens", async () => {
            const deployerBalanceToken1 = await simpleToken.balanceOf(deployer)
            const deployerBalanceToken2 = await sampleToken.balanceOf(deployer)
            assert.equal(deployerBalanceToken1, mintAmount)
            assert.equal(deployerBalanceToken2, mintAmount)
        })
    })
    describe("Liquidity pool part", () => {
        beforeEach("Adds the initial liquidity", async () => {
            await simpleToken.approve(liquidityPool.target, mintAmount)
            await sampleToken.approve(liquidityPool.target, mintAmount)
            await liquidityPool.addInitialLiquidity(mintAmount, mintAmount)
        })
        it("Checks the initial liquidity", async () => {
            //ADDS THE LIQUIDITY
            expect(await liquidityPool.getAssetBalace(simpleToken.target)).to.equal(mintAmount)
            const liquidity = await liquidityPool.getLiquidity()
            expect(await liquidityPool.getLpTokenQuantity(deployer)).to.equal(liquidity)
            expect((await liquidityPool.assetOnePrice()) / ethers.parseEther("1")).to.equal("1")
            expect((await liquidityPool.assetTwoPrice()) / ethers.parseEther("1")).to.equal("1")
        })
        it("Time checker initial liquidity", async () => {
            await expect(liquidityPool.removeLiquidity("100")).to.be.reverted
            expect(await liquidityPool.isTimeInitialLiquidity()).to.equal(false)
            await network.provider.request({
                method: "evm_increaseTime",
                params: [31557600],
            })
            await network.provider.request({
                method: "evm_mine",
                params: [],
            })
            expect(await liquidityPool.isTimeInitialLiquidity()).to.equal(true)
        })
        it("Add additional liquidity", async () => {
            await simpleToken.mint(deployer, mintAmount)
            await sampleToken.mint(deployer, mintAmount)
            await simpleToken.approve(liquidityPool.target, mintAmount)
            await sampleToken.approve(liquidityPool.target, mintAmount)
            await liquidityPool.addLiquidity(simpleToken.target, sampleToken.target, mintAmount)
            const liquidity = await liquidityPool.getLiquidity()
            expect(await liquidityPool.getLpTokenQuantity(deployer)).to.equal(liquidity)
            expect((await liquidityPool.assetOnePrice()) / ethers.parseEther("1")).to.equal("1")
            expect((await liquidityPool.assetTwoPrice()) / ethers.parseEther("1")).to.equal("1")
        })
    })
})
