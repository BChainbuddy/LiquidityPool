const { ethers } = require("hardhat")

async function deployInitialLiquidity() {
    console.log("Connecting to the contracts...")
    const { deployer } = await getNamedAccounts()
    const poolTracker = await ethers.getContract("PoolTracker", deployer)
    const token1 = await ethers.getContractAt(
        "RandomToken",
        "0xC07EF8121DaaaE05B4754ffF795F9d18E3D5Cd77"
    )
    const token2 = await ethers.getContractAt(
        "RandomToken",
        "0xDe25e7B2e6F5E8147Bd970bE9b8d74484FD20753"
    )
    // const token3 = await ethers.getContract("TestToken2", deployer);
    console.log(`This is the pool tracker address ${poolTracker.target}`)
    console.log(`This is the token1 address ${token1.target}`)
    console.log(`This is the token2 address ${token2.target}`)
    // console.log(`This is the token3 address ${token3.target}`);
    console.log("Connected to the contract!")

    console.log("Deploying the pool...")
    console.log("Approving token...")
    console.log(poolTracker.target)
    // await token3.approve(poolTracker.target, ethers.parseEther("1000"));
    console.log(`This is the deployer token1 balance ${await token1.balanceOf(deployer)}`)
    console.log(`This is the deployer token2 balance ${await token2.balanceOf(deployer)}`)
    // console.log(
    //   `This is the deployer token2 balance ${await token3.balanceOf(deployer)}`
    // );
    console.log("Approving token1...")
    const txApprove1 = await token1.approve(poolTracker.target, ethers.parseEther("30"))
    await txApprove1.wait(1)
    console.log("Approving token2...")
    const txApprove2 = await token2.approve(poolTracker.target, ethers.parseEther("30"))
    await txApprove2.wait(1)
    console.log(
        `This is the deployer token1 allowance ${await token1.allowance(
            deployer,
            poolTracker.target
        )}`
    )
    console.log(
        `This is the deployer token2 allowance ${await token2.allowance(
            deployer,
            poolTracker.target
        )}`
    )
    console.log("Tokens approved!")
    console.log("Creating Pool...")
    const tx = await poolTracker.createPool(
        token1.target,
        token2.target,
        ethers.parseEther("20"),
        ethers.parseEther("20")
    )
    await tx.wait(1)
    console.log("Pool deployed!")
}

deployInitialLiquidity()
    .then(() => {
        process.exit(0)
    })
    .catch((e) => {
        console.error(e)
        process.exit(1)
    })
