// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.7;

// // Importing required contracts and interfaces
// import "./PoolTracker.sol";
// import "./LiquidityPool.sol";
// import "@openzeppelin/contracts/interfaces/IERC20.sol";

// // Importing CCIP
// import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
// import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
// import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
// import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";

// // Error declaration for unswappable token pairs
// error SwapRouter_tokensCantBeSwapped();
// error SwapRouter_needToCallExistingFunction();
// error SwapRouter_NotEnoughBalance();
// error SwapRouter_ChainNotAvailable();

// /**
//  * @title SwapRouter
//  * @dev Facilitates token swaps utilizing defined liquidity pools, offering direct swaps and routed swaps through an intermediary.
//  * Leverages the PoolTracker contract to access liquidity pool information and perform asset exchanges.
//  */
// contract SwapRouterCCIP is CCIPReceiver, OwnerIsCreator {
//     // Emitted after a successful token swap
//     event swap(
//         address userAddress,
//         address address1,
//         address address2,
//         uint256 address1Amount,
//         uint256 address2Amount
//     );

//     // Reference to the PoolTracker contract for pool operations
//     PoolTracker poolTracker;

//     // Reentrancy Guard
//     bool internal locked;

//     /**
//      * @dev Modifier to prevent reentrancy attacks.
//      */
//     modifier noReentrancy() {
//         require(!locked, "No re-entrancy");
//         locked = true;
//         _;
//         locked = false;
//     }

//     /**
//      * @param tracker Address of the PoolTracker contract instance.
//      */
//     constructor(address tracker, address _router) CCIPReceiver(_router) {
//         poolTracker = PoolTracker(tracker);
//     }

//     /**
//      * @notice Swaps `inputAmount` of `address1` tokens for `address2` tokens.
//      * @dev This function supports direct swaps between tokens in a single pool or routed swaps through an intermediary token.
//      * Uses PoolTracker to determine the best swap path and perform the exchange.
//      * @param address1 The token being sold by the user.
//      * @param address2 The token being purchased by the user.
//      * @param inputAmount The amount of `address1` tokens to swap.
//      */
//     function swapAsset(
//         address address1,
//         address address2,
//         uint256 inputAmount
//     ) public payable noReentrancy {
//         if (poolTracker.exists(address1, address2)) {
//             // Direct swap scenario
//             LiquidityPool pool = poolTracker.pairToPool(address1, address2);
//             uint256 startingBalanceAddress2 = IERC20(address2).balanceOf(address(this));
//             if (pool.assetOneAddress() == address1) {
//                 IERC20(address1).transferFrom(msg.sender, address(this), inputAmount);
//                 IERC20(address1).approve(address(pool), inputAmount);
//                 pool.sellAssetOne{value: pool.swapFee()}(inputAmount);
//             } else {
//                 IERC20(address1).transferFrom(msg.sender, address(this), inputAmount);
//                 IERC20(address1).approve(address(pool), inputAmount);
//                 pool.sellAssetTwo{value: pool.swapFee()}(inputAmount);
//             }
//             uint256 amountOutput = IERC20(address2).balanceOf(address(this)) -
//                 startingBalanceAddress2;
//             IERC20(address2).transfer(msg.sender, amountOutput);
//             // Unrequired fee
//             uint256 unrequiredFee = msg.value - pool.swapFee(); // In case the msg.sender sent more value than it is required
//             (bool sent, ) = payable(msg.sender).call{value: unrequiredFee}("");
//             require(sent, "Failed to send Ether");
//         } else if (poolTracker.tokenToRoute(address1, address2) != address(0)) {
//             // Routed swap scenario
//             address routingToken = poolTracker.tokenToRoute(address1, address2);
//             LiquidityPool pool1 = poolTracker.pairToPool(address1, routingToken);
//             LiquidityPool pool2 = poolTracker.pairToPool(address2, routingToken);
//             uint256 startingBalance = IERC20(routingToken).balanceOf(address(this));
//             uint256 startingBalance2 = IERC20(address2).balanceOf(address(this));
//             //SWAP 1, input token into routing  token
//             if (pool1.assetOneAddress() == address1) {
//                 IERC20(address1).transferFrom(msg.sender, address(this), inputAmount);
//                 IERC20(address1).approve(address(pool1), inputAmount);
//                 pool1.sellAssetOne{value: pool1.swapFee()}(inputAmount);
//             } else {
//                 IERC20(address1).transferFrom(msg.sender, address(this), inputAmount);
//                 IERC20(address1).approve(address(pool1), inputAmount);
//                 pool1.sellAssetTwo{value: pool1.swapFee()}(inputAmount);
//             }
//             //SWAP 2, routing token into output token
//             uint256 routingTokenInput = IERC20(routingToken).balanceOf(address(this)) -
//                 startingBalance;
//             if (pool2.assetOneAddress() == address1) {
//                 IERC20(routingToken).approve(address(pool2), routingTokenInput);
//                 pool2.sellAssetOne{value: pool2.swapFee()}(routingTokenInput);
//             } else {
//                 IERC20(routingToken).approve(address(pool2), routingTokenInput);
//                 pool2.sellAssetTwo{value: pool2.swapFee()}(routingTokenInput);
//             }
//             uint256 address2Output = IERC20(address2).balanceOf(address(this)) - startingBalance2;
//             IERC20(address2).transfer(msg.sender, address2Output);
//             // Unrequired fee
//             uint256 unrequiredFee = msg.value - pool1.swapFee() - pool2.swapFee(); // In case the msg.sender sent more value than it is required
//             (bool sent, ) = payable(msg.sender).call{value: unrequiredFee}("");
//             require(sent, "Failed to send Ether");
//         } else {
//             // Assets cant be swapped directly nor routed
//             revert SwapRouter_tokensCantBeSwapped();
//         }
//     }

//     /**
//      * @notice Estimates the output amount for a swap from `address1` to `address2` given an `inputAmount` of `address1`.
//      * @dev Considers direct swaps and routed swaps through an intermediary token, utilizing PoolTracker for calculations.
//      * @param address1 The token being sold.
//      * @param address2 The token being bought.
//      * @param inputAmount The amount of `address1` tokens to swap.
//      * @return output The estimated amount of `address2` tokens to be received.
//      */
//     function getSwapAmount(
//         address address1,
//         address address2,
//         uint256 inputAmount
//     ) public view returns (uint256) {
//         uint256 output;
//         if (poolTracker.exists(address1, address2)) {
//             LiquidityPool pool = poolTracker.pairToPool(address1, address2);
//             output = pool.getSwapQuantity(address1, inputAmount);
//         } else if (poolTracker.tokenToRoute(address1, address2) != address(0)) {
//             address routingToken = poolTracker.tokenToRoute(address1, address2);
//             LiquidityPool pool1 = poolTracker.pairToPool(address1, routingToken);
//             LiquidityPool pool2 = poolTracker.pairToPool(address2, routingToken);
//             uint256 routingOutput = pool1.getSwapQuantity(address1, inputAmount);
//             output = pool2.getSwapQuantity(routingToken, routingOutput);
//         } else {
//             // Assets cant be swapped directly nor routed
//             revert SwapRouter_tokensCantBeSwapped();
//         }
//         return output;
//     }

//     /**
//      * @dev Fallback function if address calls unexisting function, but contains msg.data
//      */
//     fallback() external payable {}

//     /**
//      * @dev Receive function if address calls unexisting function, without msg.data
//      */
//     receive() external payable {}

//     //CCIP

//     //Mapping of our swapRouter contracts
//     mapping(uint64 => address) public swapContracts;

//     //Adding swap contracts
//     function addSwapContracts(uint64 _chainId, address _swapContract) public onlyOwner {
//         swapContracts[_chainId] = _swapContract;
//     }

//     //This is the CCIP bridgin token
//     address bridgingToken; // This is the chainlink bridging token

//     //Function to add bridging token
//     function addBridgingToken(address tokenAddress) public onlyOwner {
//         bridgingToken = tokenAddress;
//     }

//     //Sends the swap request to Swap Router on a different chain
//     //It would be good to check if we can the list of tradable tokens on the other chain, however frontend could implement list to spend less gas
//     //If fee not high enough it wont perform the swap, use more fee in that case(the contract returns unrequired fee)
//     function sendSwapRequest(
//         uint64 _destinationChain, //Destination Chain
//         address address1, //Input swap token
//         address address2, //Output swap token(must be address of an asset on the other chain)
//         uint256 inputAmount //Input token Amount
//     ) public payable returns (bytes32 messageId) {
//         //Checking the mappings with our dexes to see if available
//         address _receiver = swapContracts[_destinationChain];
//         if (_receiver == address(0)) {
//             revert SwapRouter_ChainNotAvailable();
//         }
//         //PERFORM SWAP
//         if (poolTracker.exists(address1, address2)) {
//             // Direct swap scenario
//             LiquidityPool pool = poolTracker.pairToPool(address1, address2);
//             uint256 startingBalanceAddress2 = IERC20(address2).balanceOf(address(this));
//             if (pool.assetOneAddress() == address1) {
//                 IERC20(address1).transferFrom(msg.sender, address(this), inputAmount);
//                 IERC20(address1).approve(address(pool), inputAmount);
//                 pool.sellAssetOne{value: pool.swapFee()}(inputAmount);
//             } else {
//                 IERC20(address1).transferFrom(msg.sender, address(this), inputAmount);
//                 IERC20(address1).approve(address(pool), inputAmount);
//                 pool.sellAssetTwo{value: pool.swapFee()}(inputAmount);
//             }
//             uint256 amountOutput = IERC20(address2).balanceOf(address(this)) -
//                 startingBalanceAddress2;
//             IERC20(address2).transfer(msg.sender, amountOutput);
//             // Unrequired fee
//             uint256 unrequiredFee = msg.value - pool.swapFee(); // In case the msg.sender sent more value than it is required
//             (bool sent, ) = payable(msg.sender).call{value: unrequiredFee}("");
//             require(sent, "Failed to send Ether");
//         } else {
//             revert SwapRouter_tokensCantBeSwapped();
//         }
//         uint256 _amountBridginToken; // get from the swap(routing token output)
//         //SEND MESSAGE AND TOKENS
//         Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
//             _receiver,
//             address2,
//             _amountBridginToken,
//             bridgingToken,
//             msg.sender
//         );
//         IRouterClient router = IRouterClient(this.getRouter());

//         uint256 fees = router.getFee(_destinationChain, evm2AnyMessage);

//         if (fees > address(this).balance) {
//             revert SwapRouter_NotEnoughBalance();
//         }

//         // approve the Router to spend tokens on contract's behalf. It will spend the amount of the given token
//         IERC20(bridgingToken).approve(address(router), _amountBridginToken);

//         // Send the message through the router and store the returned message ID
//         messageId = router.ccipSend{value: fees}(_destinationChain, evm2AnyMessage);
//         return messageId;
//     }

//     /// Handle a received message
//     function _ccipReceive(
//         Client.Any2EVMMessage memory any2EvmMessage // The message the SwapRouter receives
//     ) internal override {
//         // Save message
//         s_lastReceivedMessageId = any2EvmMessage.messageId;
//         s_lastReceivedTokenAddress = any2EvmMessage.destTokenAmounts[0].token;
//         s_lastReceivedTokenAmount = any2EvmMessage.destTokenAmounts[0].amount;
//         // abi-decoding of the sent data
//         (address outputToken, uint256 amount, address user) = abi.decode(
//             any2EvmMessage.data,
//             (address, uint256, address)
//         );
//         // If user doesnt have the balance to pay for fees, we give him back tokens
//         LiquidityPool pool = poolTracker.pairToPool(bridgingToken, outputToken);
//         if (feeBalance[user] < pool.getSwapFee() || address(pool) == address(0)) {
//             IERC20(bridgingToken).transfer(user, amount);
//             revert SwapRouter_tokensCantBeSwapped();
//         }
//         // SWAP LOGIC
//         // Direct swap scenario, cant do indirect(thus we need to provide enough pools in our dex with this token)
//         uint256 startingBalanceAddress2 = IERC20(outputToken).balanceOf(address(this));
//         if (pool.assetOneAddress() == bridgingToken) {
//             IERC20(bridgingToken).approve(address(pool), amount);
//             pool.sellAssetOne{value: pool.swapFee()}(amount);
//         } else {
//             IERC20(bridgingToken).approve(address(pool), amount);
//             pool.sellAssetTwo{value: pool.swapFee()}(amount);
//         }
//         uint256 amountOutput = IERC20(outputToken).balanceOf(address(this)) -
//             startingBalanceAddress2;
//         IERC20(outputToken).transfer(user, amountOutput);
//         // Deduct the fee
//         feeBalance[user] -= pool.swapFee();
//     }

//     function _buildCCIPMessage(
//         address _receiverContract, // The SwapRouter contract where the tokens will get delivered
//         address outputToken, // Receiving message
//         uint256 routingInputAmount, // Receiving message and transfer
//         address _token, // Bridging token(provided by Chainlink)
//         address _receiverUser // User that will receive tokens
//     ) private pure returns (Client.EVM2AnyMessage memory) {
//         // Set the token amounts
//         Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
//         tokenAmounts[0] = Client.EVMTokenAmount({token: _token, amount: routingInputAmount});
//         // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
//         return
//             Client.EVM2AnyMessage({
//                 receiver: abi.encode(_receiverContract), // ABI-encoded receiver address
//                 data: abi.encodePacked(outputToken, routingInputAmount, _receiverUser), // ABI-encoded parameters
//                 tokenAmounts: tokenAmounts, // The amount and type of token being transferred
//                 extraArgs: Client._argsToBytes(
//                     // Additional arguments, setting gas limit
//                     Client.EVMExtraArgsV1({gasLimit: 200_000})
//                 ),
//                 // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
//                 feeToken: address(0)
//             });
//     }

//     // Message saved
//     bytes32 private s_lastReceivedMessageId; // Store the last received messageId.
//     address private s_lastReceivedTokenAddress; // Store the last received token address.
//     uint256 private s_lastReceivedTokenAmount; // Store the last received amount.

//     /**
//      * @notice Returns the details of the last CCIP received message.
//      * @dev This function retrieves the ID, text, token address, and token amount of the last received CCIP message.
//      * @return messageId The ID of the last received CCIP message.
//      * @return tokenAddress The address of the token in the last CCIP received message.
//      * @return tokenAmount The amount of the token in the last CCIP received message.
//      */
//     function getLastReceivedMessageDetails()
//         public
//         view
//         returns (bytes32 messageId, address tokenAddress, uint256 tokenAmount)
//     {
//         return (s_lastReceivedMessageId, s_lastReceivedTokenAddress, s_lastReceivedTokenAmount);
//     }

//     // Mapping to see how much fee the user has deposited to the contract
//     mapping(address => uint256) public feeBalance;

//     // Function for user to add fees to his fees balance(used for swaping CCIP)
//     function addFeeBalance() public payable {
//         feeBalance[msg.sender] += msg.value;
//     }
// }
