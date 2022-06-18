pragma solidity ^0.8.6;
import "./Liquidity_pool.sol";

contract Stats {
    Liquidity_pool lp;
    uint k_values[] = new uint[](10);
    uint profit[] = new uint[](10); 

    constructor(Liquidity_pool _lp) {
       lp = _lp;
    }

    function GetStats() public view returns (bytes memory) 
    {
     return string.concat(
            "   the k of the pool:",
            abi.encodePacked(lp.getK()),
            "   total funds of the pool:",
            abi.encodePacked(lp.getFunds()),
            "   total locked profit of liquidity:",
            abi.encodePacked(lp.getFundsLocked())
        );
    }


}