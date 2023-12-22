const { ethers } = require("hardhat")

async function swapAsset() {
    console.log("Connecting to contracts...")
    const amount = ethers.parseEther("10")
    const liquidityPool = await ethers.getContract("LiquidityPool")
    const simpleToken = await ethers.getContract("SimpleToken")
    console.log("Connection to contracts successful!")
    console.log("Approving assetOne...")
    await simpleToken.approve(liquidityPool.target, amount)
    console.log("Amount approved!")
    console.log("Selling Asset One...")
    await liquidityPool.sellAssetOne(amount, { value: ethers.parseEther("0.05") })
    console.log("Asset One sold!")
}

swapAsset()
    .then(() => {
        process.exit(0)
    })
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
