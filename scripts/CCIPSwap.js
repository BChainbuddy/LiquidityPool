const { ethers, getNamedAccounts } = require("hardhat");

async function CCIPSwap(bridgingToken, swapContract, chainId) {
  console.log("Connecting to the contracts...");
  const { deployer } = await getNamedAccounts();
  const swapRouter = await ethers.getContract("SwapRouter", deployer);
  const token1 = await ethers.getContract("TestToken1", deployer);
  const token2 = await ethers.getContract("TestToken2", deployer);
  const swapAmount = ethers.parseEther("10");
  console.log("Connected to the contract!");

  // Approving token
  console.log("Approving the swap amount...");
  await token1.approve(swapRouter.target, swapAmount);
  await token1.allowance(deployer, swapRouter.target);
  console.log("Token swap amount Approved!");

  // Performing the swap
  console.log("Adding bridging token...");
  await swapRouter.addBridgingToken(bridgingToken);
  console.log("Bridging token added!");
  console.log("Adding destination swapRouter...");
  await swapRouter.addSwapContracts(chainId, swapContract);
  console.log("Swap contract added!");
  console.log("Sending message to Swap Router...");
  const messageId = await swapRouter.sendSwapRequest(
    _destinationChain,
    token1,
    token2,
    swapAmount,
    { value: ethers.parseEther("1") }
  );
  console.log(`Message sent, this is the ID ${messageId}`);
}

CCIPSwap()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
