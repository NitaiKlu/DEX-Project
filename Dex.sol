// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;
/// @title Liquidit_pair_pool Contract 

import "./ownable.sol";
import "./Liquidity_pool.sol";
import "./PoolToken.sol";

contract Dex is Ownable {
    IERC20 liquidityToken;
    mapping(address => bool) public poolsExist;
    address[] pools;
    
    constructor() {
        liquidityToken = new PoolToken("BurgerSwap", "BS", 18, 100000000000);
    }
    
    function requestFromPool(uint amount) public {
        if(poolsExist[msg.sender]) {
            liquidityToken.transfer(msg.sender, amount);
        }
    }
    
    function liquidityTokenAddress() public view returns (address) {
       return address(liquidityToken);
    }
    
    
    function takeControlPool(address liquidityPool) onlyOwner public {
        require(Liquidity_pool(liquidityPool).owner() == address(this), "This Dex is not the owner of the pool.");
        pools.push(liquidityPool);
        poolsExist[liquidityPool] = true;
        IERC20(liquidityToken).approve(liquidityPool, 100000);
    }

}