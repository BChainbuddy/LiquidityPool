const { ethers } = require("hardhat")

async function deployInitialLiquidity() {
    const amount = ethers.parseEther("100")
    console.log("Connecting to the contracts...")
    const liquidityPool = await ethers.getContract("LiquidityPool")
    const sampleToken = await ethers.getContract("SampleToken")
    const simpleToken = await ethers.getContract("SimpleToken")
    console.log("Contract connections successfull!")
    console.log("Approving token allowance...")
    await sampleToken.approve(liquidityPool, amount)
    await simpleToken.approve(liquidityPool, amount)
    console.log("Allowance approved!")
    console.log("Deploying Initial Liquidity...")
    await liquidityPool.addInitialLiquidity(amount, amount)
    console.log("Initial liquidity deployed successfully!")
}

deployInitialLiquidity()
    .then(() => {
        process.exit(0)
    })
    .catch((e) => {
        console.error(e)
        process.exit(1)
    })
