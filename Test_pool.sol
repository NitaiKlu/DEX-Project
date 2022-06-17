// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "./Liquidity_pool.sol";
import "./TokenA.sol";
import "./TokenB.sol";
/// @title ERC20 Contract - a token to change with 

contract Test {
    string public test_name;
    uint public total_supply_A;
    uint public total_supply_B;
    string public description;
    IERC20 token_a;
    IERC20 token_b;

    constructor(string memory _name, string memory _description, uint _totalSupply_A, uint _totalSupply_B, ) {
        test_name = _name;
        description = _description;
        total_supply_A = _totalSupply_A;
        total_supply_B = _totalSupply_B;
        token_a = new TokenA("token_a", "TKA", 10, 10000000000);
        token_b = new TokenB("token_a", "TKB", 10, 10000000000);
    }

    
}