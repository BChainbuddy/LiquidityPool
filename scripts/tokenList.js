const { ethers } = require("hardhat")

async function tokenList() {
    console.log("Connecting to the contracts...")
    const poolTracker = await ethers.getContract("PoolTracker")
    console.log("Contract connections successfull!")
    console.log("Retrieving token list...")
    const list = await poolTracker.tokenList()
    console.log(list)
}

tokenList()
    .then(() => {
        process.exit(0)
    })
    .catch((e) => {
        console.error(e)
        process.exit(1)
    })
