// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;
/// @title Liquidit_pair_pool Contract 

import "./Liquidity_pool.sol";

contract Dex {
    struct pair {
        string constant name1;
        string constant name2;
    }
    // fields:
    uint public constant number_of_pairs = 2; //that means we support 3 coins A<-->B, B<-->C
    uint public constant number_of_coins = 3;
    uint public total_supply;
    Liquidity_pool[number_of_pairs] public pools; //pools in the DEX
    pair[number_of_pairs] public pairs; //different pair of coins names
    uint[number_of_coins] public ratios; //the ratio of each token to USD

    constructor(uint _totalSupply) {
        total_supply = _total_supply;
        pair first;
        pair second;
        first.name1 = "coin_A";
        first.name2 = "coin_B";
        second.name1 = "coin_B";
        second.name2 = "coin_C";
        ratios[0] = 1;
        ratios[1] = 1;
        ratios[2] = 1;
    }

    /// @notice exchange 'amount' from provided to desired coin
    /// @param amount amount of the coin provided
    /// @param provided_coin the coin that will be added to the pool
    /// @param desired_coin the coin that will be taken from the pool
    function exchange(uint amount, string provided_coin, string desired_coin) payable public {
        // require() enough money in the sender's account
        // find the path of the coin exchange (direct or indirect)
        // activate the exchange() of the pool(s)
        // send the address as a parameter
    }

    /// @notice a donor donates some tokens to a specific pool of this pair. 
    /// @param amount the amount of money from provided_coin 
    /// @param provided_coin the first of the pair of coins
    /// @param second_coin the second coin from which the donor brings the same relative amount
    function donate(uint amount, string provided_coin, string second_coin ) payable public {
        // require() both coins to have a pair
        // require() both coins to be of equal amount
        // activate the function donate() of the correct pool
        // send the msg.sender's address as a parameter
    }

    /// @notice a donor redeems the money he donated. 
    function redeem() payable public {
        // activate redeem(), parameters are the sender's address
    }

}