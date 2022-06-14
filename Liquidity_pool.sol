// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./ownable.sol";
import "./PriceConsumerV3.sol";
import "./ERC20_token/IERC20.sol";
import "./PoolToken.sol";

/// @title Liquidity_pair_pool Contract 

contract Liquidity_pool is Ownable {
    // fields:
    IERC20 public tokenA;
    IERC20 public tokenB;
    PoolToken public liquidityToken;
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

    constructor(uint _initial_A, uint _initial_B,IERC20 _tokenA,IERC20 _tokenB, PoolToken _liquidityToken) {
        tokenA = new _tokenA();
        tokenB = new _tokenB();
        liquidityToken = new _liquidityToken(); 
        // i don't think there should be any liquidity
        // to start with people will use the deposit function to add funds
        amount_A = _initial_A;
        amount_B = _initial_B;
        // TODO add the address of the token/USD feed we want to add 
        priceFeedTokenA = new PriceConsumerV3();
        priceFeedTokenB = new PriceConsumerV3();
       uint exchange_value_A;
        exchange_value_A = priceFeedTokenA.getLatestPrice();
        uint exchange_value_B;
        exchange_value_B = priceFeedTokenB.getLatestPrice();
        total_funds_received = _initial_A*exchange_value_A + _initial_B*exchange_value_B;
        k_pool = amount_A * amount_B;
    }
    function assertOwnerAndFunds() public {
        uint exchange_value_A;
        exchange_value_A = priceFeedTokenA.getLatestPrice();
        uint exchange_value_B;
        exchange_value_B = priceFeedTokenB.getLatestPrice();
        return string.concat("The owner of this contract is address",string(owner()),". The total funds locked in this contract is",string(amount_A* exchange_value_A+ amount_B* exchange_value_B));
    }

    function exchange(uint _amount, IERC20 _coin_received) payable external  {
        require((_coin_received==tokenA) || (_coin_received==tokenB));
        
        // amount is the amount of the token the user is sending us
        uint amount_minus_fee = (_amount*0.97);
        // send the 3% to all liquidity providers ?
        if(_coin_received == tokenA){
            require(tokenA.allowance(msg.sender,address(this)) >= _amount, "Not enough tokens have been allowed");
            // dy = dx*y/(x=dx)
            uint amount_sent_back = (amount_minus_fee * amount_B)/(amount_A+ amount_minus_fee);
            require(amount_sent_back<amount_B,"not enough funds to perform transaction");
            //take the funds of the user
            tokenA.transferFrom(msg.sender, address(this),_amount);
            // send back the other coins
            tokenB.transfer(msg.sender,amount_sent_back);
            //update state
            amount_A+= _amount;
            amount_B-= amount_sent_back;
        }
        else{
            require(tokenB.allowance(msg.sender,address(this)) >= _amount, "Not enough tokens have been allowed");
            // dy = dx*y/(x=dx)
            uint amount_sent_back = (amount_minus_fee * amount_A)/(amount_B+ amount_minus_fee);
            require(amount_sent_back<amount_A,"not enough funds to perform transaction");
            //take the funds of the user
            tokenB.transferFrom(msg.sender, address(this),_amount);
            //send back the other coins
            tokenA.transfer(msg.sender, amount_sent_back);
            //update state
            amount_A-= amount_sent_back;
            amount_B+= _amount;

        }
    }
    function donate(uint _amount_coin_A, uint _amount_coin_B) payable public {
        uint exchange_value_A;
        exchange_value_A = priceFeedTokenA.getLatestPrice();
        uint exchange_value_B;
        exchange_value_B = priceFeedTokenB.getLatestPrice();
        
        uint amount_coin_A_dollars = _amount_coin_A* exchange_value_A;
        uint amount_coin_B_dollars = _amount_coin_B* exchange_value_B;
        require(amount_coin_A_dollars == amount_coin_B_dollars, "The value provided is not the same for each token");
        require(tokenA.allowance(msg.sender,address(this)) >= _amount_coin_A, "Not enough {tokenA} have been allowed");
        require(tokenB.allowance(msg.sender,address(this)) >= _amount_coin_B, "Not enough {tokenB} have been allowed");
        // get the funds from the user 
        tokenA.transferFrom(msg.sender, address(this), _amount_coin_A);
        tokenB.transferFrom(msg.sender, address(this), _amount_coin_B);
        // send him back liquidityTokens
        liquidityToken.transfer(msg.sender,amount_coin_A_dollars*2);
        donors[msg.sender]+= amount_coin_A_dollars*2;
        //update state
        amount_A+= _amount_coin_A;
        amount_B+= _amount_coin_B;
        k_pool = amount_A * amount_B;
        total_funds_received+= amount_coin_A_dollars*2;
    }

    function redeem(uint _amount) payable public {
        require(liquidityToken.allowance(msg.sender,address(this)) >= _amount, string(abi.encodePacked("Not enough", string(liquidityToken) ,"have been allowed")));
        //assert the person claiming is the liquidity provider
        require(donors[msg.sender]>=_amount);
        uint share_pool = (_amount/total_funds_received);
        
        uint exchange_value_A;
        exchange_value_A = priceFeedTokenA.getLatestPrice();
        uint exchange_value_B;
        exchange_value_B = priceFeedTokenB.getLatestPrice();
        
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
        tokenA.transfer(msg.sender, to_send_A);
        tokenB.transfer(msg.sender, to_send_B);
        k_pool = amount_A * amount_B;
    }


}