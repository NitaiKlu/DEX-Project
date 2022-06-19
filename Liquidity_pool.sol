// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./ownable.sol";
import "./PriceConsumerV3.sol";
import "./ERC20_token/IERC20.sol";
import "./PoolToken.sol";
import "./Strings.sol";

/// @title Liquidity_pair_pool Contract 

contract Liquidity_pool is Ownable {
    // fields:
    address public tokenA;
    address public tokenB;
    address public liquidityToken;
    mapping (address => uint) donors;
    uint private k_pool;
    uint private total_funds_locked;
    uint private total_funds_received;
    uint private amount_A;
    uint private amount_B;
    PriceConsumerV3 internal priceFeedTokenA;
    PriceConsumerV3 internal priceFeedTokenB;
    // onlyOwner() can be used at the end of a function
    // to make sure that only the owner of the contract can use the function

    constructor(uint _initial_A, uint _initial_B,address _tokenA,address _tokenB, address _poolToken,address dataFeedA, address dataFeedB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        liquidityToken =_poolToken; 
        amount_A = 0;
        amount_B = 0;
        // TODO add the address of the token/USD feed we want to add 
        // for now i put  
        // ETH/USD : 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        // BTC/USD : 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c
        priceFeedTokenA = new PriceConsumerV3(dataFeedA);
        priceFeedTokenB = new PriceConsumerV3(dataFeedB);
        uint exchange_value_A;
        exchange_value_A = uint256(priceFeedTokenA.getLatestPrice());
        uint exchange_value_B;
        exchange_value_B = uint256(priceFeedTokenB.getLatestPrice());
        total_funds_received = _initial_A*exchange_value_A + _initial_B*exchange_value_B;
        k_pool = amount_A * amount_B;
    }
    function assertOwnerAndFunds() public view returns (string memory)  {
         uint exchange_value_A;
        exchange_value_A = uint256(priceFeedTokenA.getLatestPrice());
        uint exchange_value_B;
        exchange_value_B = uint256(priceFeedTokenB.getLatestPrice());
        string memory owner = Strings.toHexString(owner());
        string memory fundsValue = Strings.toString(amount_A* exchange_value_A+ amount_B* exchange_value_B);
        return Strings.concatenate("The owner of this contract is address",owner,". The total funds locked in this contract is",fundsValue);
    }

    function exchange(uint _amount, address _coin_received) payable external  {
        require((_coin_received==tokenA) || (_coin_received==tokenB));
        
        // amount is the amount of the token the user is sending us
        // need to multiply then divide by 100 to get the 3% and not nother data type
        uint amount_minus_fee = uint((_amount*(0.97*100))/100);
        // send the 3% to all liquidity providers ?
        if(_coin_received == tokenA){
            require(IERC20(tokenA).allowance(msg.sender,address(this)) >= _amount, "Not enough tokens have been allowed");
            // dy = dx*y/(x=dx)
            uint amount_sent_back = (amount_minus_fee * amount_B)/(amount_A+ amount_minus_fee);
            require(amount_sent_back<amount_B,"not enough funds to perform transaction");
            //take the funds of the user
            IERC20(tokenA).transferFrom(msg.sender, address(this),_amount);
            // send back the other coins
            IERC20(tokenB).transfer(msg.sender,amount_sent_back);
            //update state
            amount_A+= _amount;
            amount_B-= amount_sent_back;
        }
        else{
            require(IERC20(tokenB).allowance(msg.sender,address(this)) >= _amount, "Not enough tokens have been allowed");
            // dy = dx*y/(x=dx)
            uint amount_sent_back = (amount_minus_fee * amount_A)/(amount_B+ amount_minus_fee);
            require(amount_sent_back<amount_A,"not enough funds to perform transaction");
            //take the funds of the user
            IERC20(tokenA).transferFrom(msg.sender, address(this),_amount);
            //send back the other coins
            IERC20(tokenA).transfer(msg.sender, amount_sent_back);
            //update state
            amount_A-= amount_sent_back;
            amount_B+= _amount;

        }
    }
    function donate(uint _amount_coin_A, uint _amount_coin_B) payable public {
         uint exchange_value_A;
        exchange_value_A = uint256(priceFeedTokenA.getLatestPrice());
        uint exchange_value_B;
        exchange_value_B = uint256(priceFeedTokenB.getLatestPrice());
        
        uint amount_coin_A_dollars = _amount_coin_A* exchange_value_A;
        uint amount_coin_B_dollars = _amount_coin_B* exchange_value_B;
        require(amount_coin_A_dollars == amount_coin_B_dollars, "The value provided is not the same for each token");
        require(IERC20(tokenA).allowance(msg.sender,address(this)) >= _amount_coin_A, "Not enough {tokenA} have been allowed");
        require(IERC20(tokenB).allowance(msg.sender,address(this)) >= _amount_coin_B, "Not enough {tokenB} have been allowed");
        // get the funds from the user 
        IERC20(tokenA).transferFrom(msg.sender, address(this), _amount_coin_A);
        IERC20(tokenB).transferFrom(msg.sender, address(this), _amount_coin_B);
        // send him back liquidityTokens
        IERC20(liquidityToken).transfer(msg.sender,amount_coin_A_dollars*2);
        donors[msg.sender]+= amount_coin_A_dollars*2;
        //update state
        amount_A+= _amount_coin_A;
        amount_B+= _amount_coin_B;
        k_pool = amount_A * amount_B;
        total_funds_received+= amount_coin_A_dollars*2;
    }

    function redeem(uint _amount) payable public {
        require(IERC20(liquidityToken).allowance(msg.sender,address(this)) >= _amount, Strings.concatenate("Not enough", Strings.toHexString(liquidityToken) ,"have been allowed"));
        //assert the person claiming is the liquidity provider
        require(donors[msg.sender]>=_amount);
        uint share_pool = (_amount/total_funds_received);
        
         uint exchange_value_A;
        exchange_value_A = uint256(priceFeedTokenA.getLatestPrice());
        uint exchange_value_B;
        exchange_value_B = uint256(priceFeedTokenB.getLatestPrice());
        
        uint amount_to_send = share_pool * (amount_A*exchange_value_A + amount_B*exchange_value_B);
        uint ratio_pool;
        if(amount_A > amount_B) {
            ratio_pool = amount_A / amount_B;
        }
        else{
            ratio_pool = amount_B / amount_A;
        }
        total_funds_received-= _amount;
        donors[msg.sender]-= _amount;
        uint to_send_A = amount_to_send/(2*exchange_value_A);
        uint to_send_B = amount_to_send/(2*exchange_value_B);
        //here the amount to send to a and b should have the same relation as the pool
        amount_A-= to_send_A;
        amount_B-= to_send_B;
        IERC20(tokenA).transfer(msg.sender, to_send_A);
        IERC20(tokenB).transfer(msg.sender, to_send_B);
        k_pool = amount_A * amount_B;
    }


}