// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {SubscriptionBasedVRFConsumer} from "./../../src/SubscriptionBasedVRFConsumer.sol";
import {SubscriptionVRF_HelperConfig} from "./../helper-configs/SubscriptionVRF_HelperConfig.s.sol";
import {LOCAL_CHAIN_ID} from "helper-config.sol";

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract DeploySubscriptionVRFV2_5 is Script {
    function run()
        public
        returns (SubscriptionBasedVRFConsumer, SubscriptionVRF_HelperConfig)
    {
        SubscriptionVRF_HelperConfig helperConfig = new SubscriptionVRF_HelperConfig();
        SubscriptionVRF_HelperConfig.NetworkConfig memory config = helperConfig
            .getConfig();

        vm.startBroadcast();

        SubscriptionBasedVRFConsumer vrfConsumer = new SubscriptionBasedVRFConsumer(
                config.vrfCoordinatorV2_5,
                config.subscriptionId,
                config.callbackGasLimit,
                config.gasLane
            );

        if (block.chainid == LOCAL_CHAIN_ID) {
            VRFCoordinatorV2_5Mock vrfMock = VRFCoordinatorV2_5Mock(
                config.vrfCoordinatorV2_5
            );
            vrfMock.addConsumer(config.subscriptionId, address(vrfConsumer));
        }

        vm.stopBroadcast();

        return (vrfConsumer, helperConfig);
    }
}
