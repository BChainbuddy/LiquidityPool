const { ethers, network } = require("hardhat")
const fs = require("fs")

const FRONT_END_ADDRESSES_FILE = "../DEX/src/constants/LiquidityPoolAddress.json"
const FRONT_END_ABI_FILE = "../DEX/src/constants/LiquidityPoolAbi.json"

module.exports = async function () {
    if (process.env.UPDATE_FRONT_END) {
        console.log("Updating front end...")
        await updateContractAddresses()
        await updateAbi()
    }
}

//FUNCTION TO UPDATE ABI JSON FILES IN FRONTEND
async function updateAbi() {
    const LiquidityPool = await ethers.getContract("LiquidityPool")
    fs.writeFileSync(FRONT_END_ABI_FILE, JSON.stringify(LiquidityPool.interface.fragments))
}

//FUNCTION TO UPDATE CONTRACT ADDRESSESS FILES IN FRONTEND
async function updateContractAddresses() {
    const LiquidityPool = await ethers.getContract("LiquidityPool")
    const chainId = network.config.chainId.toString()
    const contractAddresses = JSON.parse(fs.readFileSync(FRONT_END_ADDRESSES_FILE, "utf8"))
    if (chainId in contractAddresses) {
        if (!contractAddresses[chainId].includes(LiquidityPool.target)) {
            contractAddresses[chainId].push(LiquidityPool.target)
        }
    } else {
        contractAddresses[chainId] = [LiquidityPool.target]
    }
    fs.writeFileSync(FRONT_END_ADDRESSES_FILE, JSON.stringify(contractAddresses))
}

module.exports.tags = ["all", "frontend"]
