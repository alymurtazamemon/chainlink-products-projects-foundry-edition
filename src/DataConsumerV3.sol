// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract DataConsumerV3 {
    AggregatorV3Interface internal dataFeed;

    // * Timeout should be according to the heartbeat value of price feed.
    uint256 private constant TIMEOUT = 1 hours; // 60 * 60 = 3600s

    error DataConsumerV3__IncorrectAnswer(int answer);
    error DataConsumerV3__UpdateTimeIsZero();
    error DataConsumerV3__StalePrice();

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
            uint updatedAt, // * Timestamp of when the round was updated.
            /*uint80 answeredInRound*/ // * Deprecated - Previously used when answers could take multiple rounds to be computed
        ) = dataFeed.latestRoundData();

        if (answer <= 0) {
            revert DataConsumerV3__IncorrectAnswer(answer);
        }

        if (updatedAt == 0) {
            revert DataConsumerV3__UpdateTimeIsZero();
        }

        uint256 secondsSince = block.timestamp - updatedAt;
        if (secondsSince > TIMEOUT) revert DataConsumerV3__StalePrice();

        return answer;
    }

    function getVersion() external view returns (uint256) {
        return dataFeed.version();
    }

    function getDecimals() external view returns (uint8) {
        return dataFeed.decimals();
    }
}
