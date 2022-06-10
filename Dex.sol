// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;
/// @title Liquidit_pair_pool Contract 

import "./Liquidity_pool.sol";

contract Dex {
    struct pair {
        string name1;
        string name2;
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
        pair[0] = first;
        pair[1] = second;
        ratios[0] = 1;
        ratios[1] = 1;
        ratios[2] = 1;
    }

    /// @notice exchange 'amount' from provided to desired coin
    /// @param amount amount of the coin provided
    /// @param provided_coin the coin that will be added to the pool
    /// @param desired_coin the coin that will be taken from the pool
    function exchange(uint amount, string memory provided_coin, string memory desired_coin) payable public {
        // find the path of the coin exchange (direct or indirect):
        uint coin_pair = find_pair(provided_coin, desired_coin);
        // activate the exchange() of the pool(s):
        if(coin_pair == 0 || coin_pair == 1) {
            // A,B or B,C pools
            pools[coin_pair].exchange(msg.sender, amount);
        }
        else {
            // A,C - need to change according to how Tom builds the pool
            pools[0].exchange(msg.sender, amount);//**********need changes*/
            pools[1].exchange(msg.sender, amount);
        }
    }

    /// @notice find relevant pair
    /// @param coin1 first coin name
    /// @param coin2 second coin name
    /// @return trinary - value of {0,1,2}: 0  for A,B ; 1 for B,C ; 2 for A,C;
    function find_pair(string memory coin1, string memory coin2) internal returns (uint trinary) {
        if(keccak256(bytes(coin1)) == keccak256(bytes(pair[0].name1))){
            // coin1 == coin_A 
            if(keccak256(bytes(coin2)) == keccak256(bytes(pair[0].name2))) {
                // coin2 == coin_B
                return 0; 
            }
            else if(keccak256(bytes(coin2)) == keccak256(bytes(pair[1].name2))) {
                // coin2 == coin_C
                return 2;
            }
        }
        else if(keccak256(bytes(coin1)) == keccak256(bytes(pair[0].name2))) {
            // coin1 == coin_B
            if(keccak256(bytes(coin2)) == keccak256(bytes(pair[0].name1))) {
                // coin2 == coin_A
                return 0; 
            }
            else if(keccak256(bytes(coin2)) == keccak256(bytes(pair[1].name2))) {
                // coin2 == coin_C
                return 1;
            }
        }
        else {
            require(keccak256(bytes(coin1)) == keccak256(bytes(pair[1].name2))); //coin1 == C
            if(keccak256(bytes(coin2)) == keccak256(bytes(pair[0].name1))) {
                // coin2 == coin_A
                return 2; 
            }
            else if(keccak256(bytes(coin2)) == keccak256(bytes(pair[0].name2))) {
                // coin2 == coin_B
                return 1;
            }
        }
    }

    /// @notice a donor donates some tokens to a specific pool of this pair. 
    /// @param amount the amount of money from provided_coin 
    /// @param provided_coin the first of the pair of coins
    /// @param second_coin the second coin from which the donor brings the same relative amount
    function donate(uint amount, string memory provided_coin, string memory second_coin ) payable public {
        uint coin_pair = find_pair(provided_coin,second_coin);
        require(coin_pair != 2); //can't donate to A,C pair since they have no pool
        // activate the function donate() of the correct pool
        pools[coin_pair].donate(msg.sender, amount); //**********need changes*/
    }

    /// @notice donors redeem the money they donated. 
    function redeem(uint pool) payable public {
        pools[pool].redeem(msg.sender);
    }

}