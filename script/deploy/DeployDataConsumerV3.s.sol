// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

import {DataConsumerV3} from "../../src/DataConsumerV3.sol";
import {DataConsumerV3_HelperConfig} from "./../helper-configs/DataConsumerV3_HelperConfig.s.sol";

contract DeployDataConsumerV3 is Script {
    function run()
        public
        returns (DataConsumerV3, DataConsumerV3_HelperConfig)
    {
        DataConsumerV3_HelperConfig helperConfig = new DataConsumerV3_HelperConfig();
        address priceFeedAddress = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        DataConsumerV3 consumerV3 = new DataConsumerV3(priceFeedAddress);
        vm.stopBroadcast();

        return (consumerV3, helperConfig);
    }
}
