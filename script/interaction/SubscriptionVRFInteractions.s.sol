// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {SubscriptionBasedVRFConsumer} from "../../src/SubscriptionBasedVRFConsumer.sol";
import {LOCAL_CHAIN_ID} from "helper-config.sol";

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RequestRandomWords is Script {
    function run() external {
        console.log("Chain ID is: ", block.chainid);

        address latestContractAddress = DevOpsTools.get_most_recent_deployment(
            "SubscriptionBasedVRFConsumer",
            block.chainid
        );

        console.log(
            "Subscription VRF latest contract address is: ",
            latestContractAddress
        );

        SubscriptionBasedVRFConsumer vrfConsumer = SubscriptionBasedVRFConsumer(
            latestContractAddress
        );

        vm.startBroadcast();

        vrfConsumer.requestRandomNumber();

        uint256 lastRequestId = vrfConsumer.getLastRequestId();

        console.log("Last Request ID is: ", lastRequestId);

        if (block.chainid == LOCAL_CHAIN_ID) {
            address vrfMockAddress = DevOpsTools.get_most_recent_deployment(
                "VRFCoordinatorV2_5Mock",
                block.chainid
            );

            VRFCoordinatorV2_5Mock vrfCoordinatorV2_5Mock = VRFCoordinatorV2_5Mock(
                    vrfMockAddress
                );

            vrfCoordinatorV2_5Mock.fulfillRandomWords(
                lastRequestId,
                address(vrfConsumer)
            );
        }

        (bool status, uint256[] memory randomWords) = vrfConsumer
            .getRequestStatus(lastRequestId);

        vm.stopBroadcast();

        console.log("Status of request is: ", status);
        console.log("Random Number is: ", randomWords[0]);
    }
}
