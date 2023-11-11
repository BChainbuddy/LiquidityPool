// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/interfaces/IERC20.sol";

error assetNotCorrect();
error notEnoughTokens();
error notEnoughGas();
error notEnoughTimePassed();
error initialLiquidityAlreadyProvided();
error addressNotCorrect();
error amountTooBig();

contract LiquidityPool {
    event priceChanged(address _asset, uint256 price);
    event liquidityAdded(
        address indexed _address,
        uint256 _assetOneAmount,
        uint256 _assetTwoAmount
    );
    event liquidityRemoved(
        address indexed _address,
        uint256 _assetOneAmount,
        uint256 _assetTwoAmount
    );
    event yieldFarmed(address indexed _address, uint256 _amount);

    // ADDRESSES OF THE PROVIDED TOKENS
    address assetOneAddress;
    address assetTwoAddress;

    //LIQUIDITY AND YIELD(fees)
    uint256 public initialLiquidity;
    uint256 public liquidity;
    uint256 public yield;
    uint256 public swapFee;
    address public owner;

    constructor(address _assetOneAddress, address _assetTwoAddress) {
        // STORE THE ADDRESSES
        assetOneAddress = _assetOneAddress;
        assetTwoAddress = _assetTwoAddress;

        // SET THE OWNER
        owner = msg.sender;

        // SET INITIAL SWAP FEE IN PERCENT
        swapFee = 1;
    }

    // TRACK THE LP TOKEN QUANTITY, INITIAL LIQUIDITY
    mapping(address => uint256) public lpTokenQuantity;

    // ADD INITIAL LIQUIDITY, needs erc20 approval
    function addInitialLiquidity(
        uint256 _assetOneAmount,
        uint256 _assetTwoAmount
    ) public onlyOwner {
        if (initialLiquidityProvidedTime[owner] > 0) {
            revert initialLiquidityAlreadyProvided();
        }
        initialLiquidityProvidedTime[msg.sender] = block.timestamp;

        // SENDS THE TOKENS TO THE LIQUIDITY POOL
        IERC20(assetOneAddress).transferFrom(msg.sender, address(this), _assetOneAmount);
        IERC20(assetTwoAddress).transferFrom(msg.sender, address(this), _assetTwoAmount);

        // SET THE INITIAL LIQUIDITY
        initialLiquidity = _assetOneAmount * _assetTwoAmount;
        liquidity = initialLiquidity;

        // GIVE LP TOKENS TO THE INITIAL LIQUIDITY PROVIDER
        lpTokenQuantity[msg.sender] = initialLiquidity;

        // EMIT EVENT
        emit liquidityAdded(msg.sender, _assetOneAmount, _assetTwoAmount);
    }

    // ADD ADDITIONAL LIQUIDITY, give first and second token address, give the _amount of first asset you have, the function calculates the other side
    function addLiquidity(address _asset, address _secondAsset, uint256 _amount) public {
        // SET THE RATIO, require token balance provided in ERC20, reverted if to low
        IERC20(_secondAsset).transferFrom(
            msg.sender,
            address(this),
            amountOfOppositeTokenNeeded(_asset, _amount)
        );
        IERC20(_asset).transferFrom(msg.sender, address(this), _amount);

        // give lp tokens to new liquidity provider
        lpTokenQuantity[msg.sender] += (_amount * amountOfOppositeTokenNeeded(_asset, _amount));
        liquidity += (_amount * amountOfOppositeTokenNeeded(_asset, _amount));

        // EMIT EVENT
        emit liquidityAdded(msg.sender, amountOfOppositeTokenNeeded(_asset, _amount), _amount);
    }

    // INSERT THE PERCENTAGE OF LP TOKEN YOU WANT TO WITHDRAW
    // insert 10 for 10%, 50 for 50%, 1 for 1%,...
    function removeLiquidity(uint256 _amount) public {
        uint256 userLpTokens = lpTokenQuantity[msg.sender];
        uint256 percentageOfLiquidity = (userLpTokens * 1 ether) / liquidity; // How much user owns out of all Liquidity in percentage
        uint256 percentageOfUserLiquidity = (percentageOfLiquidity * _amount) / 100; // How much out of their liquidity they want to withdraw in percentage
        uint256 resultAssetOne = (percentageOfUserLiquidity * getAssetOne()) / 1 ether;
        uint256 resultAssetTwo = (percentageOfUserLiquidity * getAssetTwo()) / 1 ether;
        // condition for owner, because of the initial liquidity timer
        if (
            (msg.sender == owner) &&
            (isTimeInitialLiquidity() == false) &&
            //the owner has the ability to withdraw liquidity if it wasn't part of initial liquidity
            ((lpTokenQuantity[msg.sender] - (resultAssetOne * resultAssetTwo)) < initialLiquidity)
        ) {
            revert notEnoughTokens();
        }
        // check balance if it is high enough to continue, can't get reverted at transfer, it should have the balance but just in case
        if (
            IERC20(assetOneAddress).balanceOf(address(this)) < resultAssetOne ||
            IERC20(assetTwoAddress).balanceOf(address(this)) < resultAssetTwo
        ) {
            revert notEnoughTokens();
        }
        IERC20(assetOneAddress).transfer(msg.sender, resultAssetOne);
        IERC20(assetTwoAddress).transfer(msg.sender, resultAssetTwo);

        // EMIT EVENT
        emit liquidityRemoved(msg.sender, resultAssetOne, resultAssetTwo);
    }

    // GIVE ASSET ONE, GET BACK ASSET TWO
    function sellAssetOne(uint256 _amount) public payable {
        //IF THE AMOUNT IS TOO BIG FOR LIQUIDITY POOL TO RETURN
        if (_amount >= getAssetOne()) {
            payable(msg.sender).transfer(msg.value);
            revert amountTooBig();
        }
        //PAY THE ETH FEE
        uint256 requiredFee = (_amount * swapFee) / 100;
        if (msg.value < requiredFee) {
            revert notEnoughGas();
        }
        yield += requiredFee;
        uint256 unrequiredFee = msg.value - requiredFee;
        //CALCULATION
        uint256 n = getAssetTwo();
        uint256 assetOne = getAssetOne() + _amount;
        uint256 assetTwo = liquidity / assetOne;
        uint256 result = n - assetTwo;
        //SENDING THE OPPOSITE ASSET TO THE CALLER FROM LIQUIDITY POOL
        IERC20(assetOneAddress).transferFrom(msg.sender, address(this), _amount);
        IERC20(assetTwoAddress).transfer(msg.sender, result);
        payable(msg.sender).transfer(unrequiredFee);
        //EVENTS
        emit priceChanged(assetOneAddress, assetOnePrice());
        emit priceChanged(assetTwoAddress, assetTwoPrice());
    }

    // GIVE ASSET TWO, GET BACK ASSET ONE
    function sellAssetTwo(uint256 _amount) public payable {
        //IF THE AMOUNT IS TOO BIG FOR LIQUIDITY POOL TO RETURN
        if (_amount >= getAssetTwo()) {
            payable(msg.sender).transfer(msg.value);
            revert amountTooBig();
        }
        //PAY THE ETH FEE
        uint256 requiredFee = (_amount * swapFee) / 100;
        if (msg.value < requiredFee) {
            revert notEnoughGas();
        }
        yield += requiredFee;
        uint256 unrequiredFee = msg.value - requiredFee;
        //CALCULATION
        uint256 n = getAssetOne();
        uint256 assetTwo = getAssetTwo() + _amount;
        uint256 assetOne = liquidity / assetTwo;
        uint256 result = n - assetOne;
        //GETTING THE ASSET FROM CALLER TO THE LIQUIDITY POOL AND SENDING THE OPPOSITE ASSET TO THE CALLER FROM LIQUIDITY POOL
        IERC20(assetTwoAddress).transferFrom(msg.sender, address(this), _amount);
        IERC20(assetOneAddress).transfer(msg.sender, result);
        payable(msg.sender).transfer(unrequiredFee);
        //EVENTS
        emit priceChanged(assetOneAddress, assetOnePrice());
        emit priceChanged(assetTwoAddress, assetTwoPrice());
    }

    // GET THE CURRENT BALANCE OF THE ASSET THE CONTRACT OWNS
    function getAssetBalace(address _address) public view returns (uint256) {
        return IERC20(_address).balanceOf(address(this));
    }

    // GET THE CURRENT PRICE OF THE ASSET, in output divide with 1 ether (10 ** 18)
    function assetOnePrice() public view returns (uint256) {
        return (getAssetTwo() * 1 ether) / getAssetOne();
    }

    // GET THE CURRENT PRICE OF THE ASSET, in output divide with 1 ether (10 ** 18)
    function assetTwoPrice() public view returns (uint256) {
        return (getAssetOne() * 1 ether) / getAssetTwo();
    }

    // GET THE AMOUNT OF FIRST TOKEN
    function getAssetOne() public view returns (uint256) {
        return IERC20(assetOneAddress).balanceOf(address(this));
    }

    // GET THE AMOUNT OF SECOND TOKEN
    function getAssetTwo() public view returns (uint256) {
        return IERC20(assetTwoAddress).balanceOf(address(this));
    }

    // LETS THE USER SEE HOW MUCH LIQUIDITY THEY OWN, UNABLE TO SEE OTHER'S LP QUANTITY IF USER ISN'T AN OWNER
    function getLpTokenQuantity(address _address) public view returns (uint256) {
        if (msg.sender != owner && _address == msg.sender) {
            revert addressNotCorrect();
        }
        return lpTokenQuantity[_address];
    }

    // GET LIQUIDITY
    function getLiquidity() public view returns (uint256) {
        return liquidity;
    }

    // GET CURRENT SWAP FEE
    function getSwapFee() public view returns (uint256) {
        return swapFee;
    }

    // GET SWAP QUANTITY BASED ON AMOUNT, INPUT SELLING ASSET, OUTPUT AMOUNT OF SECOND ASSET THAT WOULD GET RETURNED
    function getSwapQuantity(address sellingAsset, uint256 _amount) public view returns (uint256) {
        if (sellingAsset == assetOneAddress) {
            uint256 newAssetOne = getAssetOne() + _amount;
            uint256 newAssetTwo = liquidity / newAssetOne;
            return getAssetTwo() - newAssetTwo;
        } else if (sellingAsset == assetTwoAddress) {
            uint256 newAssetTwo = getAssetTwo() + _amount;
            uint256 newAssetOne = liquidity / newAssetTwo;
            return getAssetOne() - newAssetOne;
        } else {
            revert assetNotCorrect();
        }
    }

    // GET THE SECOND PART OF LIQUIDTY TOKEN PAIR NEEDED FOR PROVIDING LIQUIDITY(We input one side, to get the other side)
    function amountOfOppositeTokenNeeded(
        address _asset,
        uint256 _amount
    ) public view returns (uint256) {
        uint256 ratio;
        if (_asset == assetOneAddress) {
            ratio = (getAssetTwo() * 1 ether) / getAssetOne();
        } else {
            ratio = (getAssetOne() * 1 ether) / getAssetTwo();
        }
        uint256 amountNeeded = (_amount * ratio) / 1 ether;
        return amountNeeded;
    }

    // GET WEEKLY FEE FOR TRANSACTIONS
    mapping(address => uint256) public yieldTaken;

    // YIELD AMOUNT
    function yieldAmount() public view returns (uint256) {
        return yield;
    }

    // CAN CALL IT ONCE A DAY
    function getYield() public {
        if (isTime() == false) {
            revert notEnoughTimePassed();
        }
        uint256 yieldSoFar = yieldTaken[msg.sender];
        uint256 userLiquidity = (lpTokenQuantity[msg.sender] * 100) / liquidity;
        uint256 availableYield = ((yield - ((yieldSoFar * 100) / userLiquidity)) * userLiquidity) /
            100;
        if (availableYield > address(this).balance) {
            revert notEnoughTokens(); // IN CASE THERE IS A LOT OF PEOPLE GETTING YIELD AT ONCE AND RATIOS GET CHANGED TOO MUCH
        }
        lastYieldFarmedTime[msg.sender] = block.timestamp;
        yieldTaken[msg.sender] += availableYield;
        payable(msg.sender).transfer(availableYield);

        // EMIT EVENT
        emit yieldFarmed(msg.sender, availableYield);
    }

    // CHANGE SWAP FEE
    modifier onlyOwner() {
        msg.sender == owner;
        _;
    }

    // FOR OWNER TO CHANGE THE SWAP FEE IF NEEDED
    function changeSwapFee(uint256 newSwapFee) public onlyOwner {
        swapFee = newSwapFee;
    }

    // TIMESTAMP MAPPING
    mapping(address => uint256) public lastYieldFarmedTime;
    mapping(address => uint256) public initialLiquidityProvidedTime;

    // DAILY TIME CHECKER
    function isTime() public view returns (bool) {
        lastYieldFarmedTime[msg.sender];
        uint256 currentStamp = block.timestamp;
        if ((lastYieldFarmedTime[msg.sender] + 1 days) < currentStamp) {
            return true;
        } else {
            return false;
        }
    }

    // INITIAL LIQUIDITY TIME CHECKER, the owner can't withdraw initial liquidity for 365 days
    function isTimeInitialLiquidity() public view returns (bool) {
        if (block.timestamp > (initialLiquidityProvidedTime[msg.sender] + 365 days)) {
            return true;
        } else {
            return false;
        }
    }

    //GET ADDRESS BALANCE
    function addressBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
