// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract DataConsumerV3 {
    AggregatorV3Interface internal dataFeed;

    /**
     * Network: Sepolia
     * Aggregator: ETH/USD
     * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    constructor(address _priceFeedAddress) {
        dataFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */, // * The round ID
            int answer, // * price
            /*uint startedAt*/, // * Timestamp of when the round started.
            /*uint updatedAt*/, // * Timestamp of when the round was updated.
            /*uint80 answeredInRound*/ // * Deprecated - Previously used when answers could take multiple rounds to be computed
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function getVersion() external view returns (uint256) {
        return dataFeed.version();
    }

    function getDecimals() external view returns (uint8) {
        return dataFeed.decimals();
    }
}
