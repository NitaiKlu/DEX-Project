// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./ownable.sol";
/// @title Liquidit_pair_pool Contract 

contract Liquidity_pool is Ownable {
    // fields:
    string public name1;
    string public name2;
    mapping (address => uint) donors;
    uint k_of_the_pool;
    uint total_funds_locked;
    uint amount_A;
    uint amount_B;
    constructor(uint _initial_A, uint _initial_B,string memory _name1,string memory _name2){

    }
    function exchange(uint _amount, string memory _coin_received) public payable {

    }
    function donate(uint _amount) public payable {

    }
    function redeem(uint _amount) public payable {

    }


}