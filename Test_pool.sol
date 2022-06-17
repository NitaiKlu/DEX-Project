// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "./Liquidity_pool.sol";
import "./Token.sol";

/// @title ERC20 Contract - a token to change with 

contract Test {
    string public test_name;
    uint public total_supply_A;
    uint public total_supply_B;
    string public description;
    Token token_a;
    Token token_b;

    constructor(string memory _name, string memory _description, uint _totalSupply_A, uint _totalSupply_B, ) {
        test_name = _name;
        description = _description;
        total_supply_A = _totalSupply_A;
        total_supply_B = _totalSupply_B;
        token_a = new TokenA("token_a", "TKA", 10, 10000000000);
        token_b = new TokenB("token_a", "TKB", 10, 10000000000);
    }

    function printDescription() public view returns(string memory) {
        return description;
    }

    function Stats() public returns(string memory) {
        return string.concat(
            "total supply of token A:",
            abi.encodePacked(token_a.getTotalSupply()),
            "   total supply of token B:",
            abi.encodePacked(token_b.getTotalSupply()), 
            "   total supply of liquidity:",
            abi.encodePacked(lp.getTotalSupply()),
            "   the init k of the pool:",
            abi.encodePacked(lp.getK()),
            "   total funds of the pool:",
            abi.encodePacked(lp.getFunds()),
            "   total locked profit of liquidity:",
            abi.encodePacked(lp.getFundsLocked());
        );
    }

    // this test is running a single LP.
    function test_1(address a_owner, address b_owner, address account3, address account4) public returns { 
        Liquidity_pool lp = new Liquidity_pool("lp token", "LPT", 10, 10000000000);
        require(false, Stats());
        // distribute money among accounts for qualitative testing:

        // donating:

        // stats:
        require(false, Stats());
        // exchangings:

        // stats:   
        require(false, Stats());
        // redeems:

        // stats:
        require(false, Stats());
    }

    
}