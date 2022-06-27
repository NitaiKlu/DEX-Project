// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./ownable.sol";
import "./PriceConsumerV3.sol";
import "./ERC20_token/IERC20.sol";
import "./PoolToken.sol";
import "./Strings.sol";
import "./Dex.sol";

/// @title Liquidity_pair_pool Contract 

contract Liquidity_pool is Ownable {
    // fields:
    address public tokenA;
    address public tokenB;
    address public liquidityToken;
    mapping (address => uint) donors;
    address[] donorsKeys;
    uint private k_pool;
    //uint private total_funds_locked;
    uint public total_funds_received;
    uint private total_revenue;

    uint private amount_A;
    uint private amount_B;
    address internal priceFeedTokenA;
    address internal priceFeedTokenB;
    // onlyOwner() can be used at the end of a function
    // to make sure that only the owner of the contract can use the function

    constructor(address _tokenA, address _tokenB, address _poolToken, address _dataFeedA, address _dataFeedB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        liquidityToken = _poolToken; 
        amount_A = 0;
        amount_B = 0;
        // for now i put  
        // DAI : 0x6B175474E89094C44Da98b954EedeAC495271d0F
        // DAI/USD : 0xaed0c38402a5d19df6e4c03f4e2dced6e29c1ee9
        // AAVE : 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9
        // AAVE/USD : 0x547a514d5e3769680ce22b2361c10ea13619e8a9
        priceFeedTokenA = _dataFeedA;
        priceFeedTokenB = _dataFeedB;
        total_funds_received = 0;
        total_revenue = 0;
        k_pool = 0;
    }


    function exchange(uint _amount, address _coin_received) payable external  {
        require((_coin_received==tokenA) || (_coin_received==tokenB), "The pool does not support this coin");
        require(IERC20(_coin_received).allowance(msg.sender,address(this)) >= _amount, "Not enough tokens have been allowed");
        // amount is the amount of the token the user is sending us
        // need to multiply then divide by 100 to get the 3% and not nother data type
        uint amount_minus_fee = uint((_amount*(0.97*100))/100);
        uint fee = _amount - amount_minus_fee;
        total_revenue+= fee;
        // send the 3% to all liquidity providers ?
        if(_coin_received == tokenA){  
            // dy = dx*y/(x+dx)
            uint amount_sent_back = (amount_minus_fee * amount_B)/(amount_A+ amount_minus_fee);
            require(amount_sent_back<amount_B,"not enough funds to perform transaction");
            //take the funds of the user
            IERC20(tokenA).transferFrom(msg.sender, address(this),_amount);
            // send back the other coins
            IERC20(tokenB).transfer(msg.sender,amount_sent_back);
            //update state
            amount_A += _amount;
            amount_B -= amount_sent_back;
        }
        else{
            // dy = dx*y/(x+dx)
            uint amount_sent_back = (amount_minus_fee * amount_A) / (amount_B+ amount_minus_fee);
            require(amount_sent_back<amount_A,"not enough funds to perform transaction");
            //take the funds of the user
            IERC20(tokenB).transferFrom(msg.sender, address(this),_amount);
            //send back the other coins
            IERC20(tokenA).transfer(msg.sender, amount_sent_back);
            //update state
            amount_A-= amount_sent_back;
            amount_B+= _amount;
        }
        
    }
    
    function donate(uint _amount_coin_A, uint _amount_coin_B) payable public {
        uint exchange_value_A;
        exchange_value_A = 2; //uint256(PriceConsumerV3(priceFeedTokenA).getLatestPrice());
        uint exchange_value_B;
        exchange_value_B = 1; //uint256(PriceConsumerV3(priceFeedTokenB).getLatestPrice());
        
        uint amount_coin_A_dollars = _amount_coin_A* exchange_value_A;
        uint amount_coin_B_dollars = _amount_coin_B* exchange_value_B;
        require(amount_coin_A_dollars == amount_coin_B_dollars, "The value provided is not the same for each token");
        require(IERC20(tokenA).allowance(msg.sender,address(this)) >= _amount_coin_A, "Not enough {tokenA} have been allowed");
        require(IERC20(tokenB).allowance(msg.sender,address(this)) >= _amount_coin_B, "Not enough {tokenB} have been allowed");
        // get the funds from the user 
        IERC20(tokenA).transferFrom(msg.sender, address(this), _amount_coin_A);
        IERC20(tokenB).transferFrom(msg.sender, address(this), _amount_coin_B);
        // send him back liquidityTokens
        IERC20(liquidityToken).transferFrom(owner(),msg.sender,amount_coin_A_dollars*2);
        donors[msg.sender]+= amount_coin_A_dollars*2;
        donorsKeys.push(msg.sender);
        //update state
        amount_A+= _amount_coin_A;
        amount_B+= _amount_coin_B;
        k_pool = amount_A * amount_B;
        total_funds_received+= amount_coin_A_dollars*2;
    }
    
    
    
    function distributeDividends() internal {
        uint exchange_value_A;
        exchange_value_A = 2; //uint256(PriceConsumerV3(priceFeedTokenA).getLatestPrice());
        uint exchange_value_B;
        exchange_value_B = 1; //uint256(PriceConsumerV3(priceFeedTokenB).getLatestPrice());
        
        // iterate over mapping
        for(uint index=0; index<donorsKeys.length; index++) {
            address donor = donorsKeys[index];
            if(0 == donors[donor]){
                continue;
            }

            uint share_pool = (donors[donor]/total_funds_received);
            uint amount_to_send = share_pool * total_revenue;
            uint to_send_A = amount_to_send/(2*exchange_value_A);
            uint to_send_B = amount_to_send/(2*exchange_value_B);
            //here the amount to send to a and b should have the same relation as the pool
            amount_A-= to_send_A;
            amount_B-= to_send_B;
            IERC20(tokenA).transfer(msg.sender, to_send_A);
            IERC20(tokenB).transfer(msg.sender, to_send_B);
        }
        k_pool = amount_A * amount_B;
        total_revenue = 0;
    }
    

    function redeem(uint _amount) payable public {
        require(IERC20(liquidityToken).allowance(msg.sender,address(this)) >= _amount,"Not enough liquidity Tokens (Burger Swap) have been allowed");
        //require(IERC20(liquidityToken).allowance(msg.sender,address(this)) >= _amount,"failed");
        //assert the person claiming is the liquidity provider
        require(donors[msg.sender]>=_amount, "You didn't contribute such an amount to the pool");
        uint share_pool = (_amount/total_funds_received);
        
        uint exchange_value_A;
        exchange_value_A = 2; //uint256(PriceConsumerV3(priceFeedTokenA).getLatestPrice());
        uint exchange_value_B;
        exchange_value_B = 1; //uint256(PriceConsumerV3(priceFeedTokenB).getLatestPrice());
        
        uint amount_to_send = share_pool * (amount_A*exchange_value_A + amount_B*exchange_value_B);
        total_funds_received-= _amount;
        donors[msg.sender]-= _amount;
        
        uint to_send_A = amount_to_send/(2*exchange_value_A);
        uint to_send_B = amount_to_send/(2*exchange_value_B);
        //here the amount to send to a and b should have the same relation as the pool
        amount_A-= to_send_A;
        amount_B-= to_send_B;
        require(IERC20(liquidityToken).transferFrom(msg.sender, owner(), _amount),"Sending liquidity tokens failed");
        require(IERC20(tokenA).transfer(msg.sender,to_send_A),"Sending coinA failed");
        require(IERC20(tokenB).transfer(msg.sender,to_send_B),"Sending coinB failed");
        k_pool = amount_A * amount_B;
    }


}