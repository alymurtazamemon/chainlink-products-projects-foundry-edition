// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

import {DataConsumerV3} from "../../src/DataConsumerV3.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {console} from "forge-std/console.sol";

contract LatestRoundData is Script {
    function run() external {
        console.log(block.chainid);

        address latestContractAddress = DevOpsTools.get_most_recent_deployment(
            "DataConsumerV3",
            block.chainid
        );

        console.log(latestContractAddress);

        vm.startBroadcast();

        int answer = DataConsumerV3(latestContractAddress)
            .getChainlinkDataFeedLatestAnswer();

        vm.stopBroadcast();

        console.logInt(answer);
    }
}
