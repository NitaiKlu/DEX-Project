// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./AggregatorV3Interface.sol";

contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Kovan
     * Aggregator: /USD
     * Address: 0x9326BFA02ADD2366b30bacB125260Af641031331
     */
    constructor(address aggregator) {
        // TODO missing the address for the price aggregator
        priceFeed = AggregatorV3Interface(aggregator);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (
            , 
            int price,
            ,
            ,
        ) = priceFeed.latestRoundData();
        return price;
    }
}