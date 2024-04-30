const { ethers } = require("hardhat")

async function poolList() {
    console.log("Connecting to the contracts...")
    const poolTracker = await ethers.getContract("PoolTracker")
    console.log("Contract connections successfull!")
    console.log("Retrieving pool list...")
    const list = await poolTracker.getPools()
    console.log(list)
}

poolList()
    .then(() => {
        process.exit(0)
    })
    .catch((e) => {
        console.error(e)
        process.exit(1)
    })
