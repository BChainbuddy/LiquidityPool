const { ethers, getNamedAccounts } = require("hardhat");

async function CCIPReceive() {
  console.log("Connecting to the contracts...");
  const { deployer } = await getNamedAccounts();
  const swapRouter = await ethers.getContract("SwapRouter", deployer);
  const token2 = await ethers.getContract("TestToken2", deployer);
  console.log("Connected to the contract!");

  // Checking balances
  console.log("Checking balances...");
  console.log(`Deployer token2 balance ${await token2.balanceOf(deployer)}`);
  console.log(`Deployer fee balance ${await swapRouter.feeBalance(deployer)}`);
  console.log(
    `This is the last received message ${await swapRouter.getLastReceivedMessageDetails()}`
  );
}

CCIPReceive()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
