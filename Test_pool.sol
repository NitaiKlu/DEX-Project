// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "./Liquidity_pool.sol";
import "./Token.sol";
import "./Stats.sol";

/// @title ERC20 Contract - a token to change with 

contract Test {
    string public test_name;
    uint public total_supply_A;
    uint public total_supply_B;
    Token token_a;
    Token token_b;
    
    constructor(string memory _name, uint _totalSupply_A, uint _totalSupply_B) {
        test_name = _name;
        total_supply_A = _totalSupply_A;
        total_supply_B = _totalSupply_B;
        token_a = new Token("token_a", "TKA", 10, 10000000000);
        token_b = new Token("token_a", "TKB", 10, 10000000000);
    }

    // this test is running a single LP.
    function test_1(address account1, address account2, address account3, address account4) public { 
        Liquidity_pool lp = new Liquidity_pool(1000000, 1000000, address(token_a), address(token_b));
        Stats stats = new Stats(lp);
        require(false, string(stats.GetStats()));
        // distribute money among accounts for qualitative testing:
        // token_a._transfer(address(this), account1, 500);
        // token_a._transfer(address(this), account2, 500);
        token_a._transfer(address(this), account3, 500);
        token_a._transfer(address(this), account4, 500);
        token_b._transfer(address(this), account1, 500);
        token_b._transfer(address(this), account2, 500);
        token_b._transfer(address(this), account3, 500);
        token_b._transfer(address(this), account4, 500);
        // approve LP spending stuff for the accounts
        token_b.approveAddress(address(lp), 500, account3);
        token_b.approveAddress(address(lp), 500, account4);
        // donating:
        lp.donateAddress(200, 100, account1); //not supposed to be authorized
        //SUPPOSED to be authorized:
        lp.donateAddress(90, 30, account3);
        lp.donateAddress(120, 40, account4);
        // stats:
        require(false, string(stats.GetStats()));
        // exchangings:
        lp.exchangeAddress(10, "bad_token_name", account1); //not supposed to be authorized - bad name
        lp.exchangeAddress(1000, "TKB", account1); //not supposed to be authorized - not enough money in the account
        lp.exchangeAddress(10, "TKB", account1);
        lp.exchangeAddress(20, "TKB", account2);
        // stats:   
        require(false, string(stats.GetStats()));
        // redeems:
        lp.redeemAddress(1000, account1); //not supposed to be authorized - too much money to redeem
        lp.redeemAddress(30, account1);
        lp.redeemAddress(30, account2);
        // stats:
        require(false, string(stats.GetStats()));
    }

    
}