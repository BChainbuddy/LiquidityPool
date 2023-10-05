const { ethers } = require("hardhat")

const networkConfig = {
    default: {
        name: "hardhat",
        keepersUpdateInterval: "30",
    },
    11155111: {
        name: "sepolia",
        vrfCoordinatorV2: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
        //get it on docs.chain.link/docs/vrf-contracts/ under goerli
        gasLane: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
        // goerli vrf contracts contract addresses 150 gwei Key Hash
        subscriptionId: "9979",
        callbackGasLimit: "500000",
        interval: "30",
        mintFee: "50000000000000000", // 0.01 ETH
        ethUsdPriceFeed: "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e",
    },
    5: {
        name: "goerli",
        vrfCoordinatorV2: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
        //get it on docs.chain.link/docs/vrf-contracts/ under goerli
        gasLane: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
        // goerli vrf contracts contract addresses 150 gwei Key Hash
        subscriptionId: "9979",
        callbackGasLimit: "500000",
        interval: "30",
        mintFee: "50000000000000000", // 0.01 ETH
        ethUsdPriceFeed: "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e",
    },
    31337: {
        name: "localhost",
        gasLane: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
        callbackGasLimit: "500000",
        interval: "30",
        subscriptionId: "0",
        mintFee: "50000000000000000", // 0.01 ETH
        ethUsdPriceFeed: "0xF9680D99D6C9589e2a93a78A04A279e509205945",
    },
    mocha: {
        timeout: 200000,
    },
}

const DECIMALS = "18"
const INITIAL_PRICE = "200000000000000000000"
const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains,
    DECIMALS,
    INITIAL_PRICE,
}
