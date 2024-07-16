// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

import {SubscriptionBasedVRFConsumer} from "./../../src/SubscriptionBasedVRFConsumer.sol";
import {SubscriptionVRF_HelperConfig} from "./../helper-configs/SubscriptionVRF_HelperConfig.s.sol";

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

        vm.stopBroadcast();

        return (vrfConsumer, helperConfig);
    }
}
