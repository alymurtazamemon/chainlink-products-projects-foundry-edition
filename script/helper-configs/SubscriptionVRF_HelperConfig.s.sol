// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

abstract contract Constants {
    uint256 public constant ETH_SEPOLIA_CHAIN_ID = 11155111;
}

contract SubscriptionVRF_HelperConfig is Constants, Script {
    mapping(uint256 chainId => NetworkConfig) public networkConfigs;

    struct NetworkConfig {
        address vrfCoordinatorV2_5; // * VRF V2.5 version
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        bytes32 gasLane;
    }

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getETHSepoliaNetworkConfig();
    }

    function getETHSepoliaNetworkConfig()
        private
        pure
        returns (NetworkConfig memory)
    {
        return
            NetworkConfig({
                vrfCoordinatorV2_5: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                subscriptionId: 0,
                callbackGasLimit: 40000,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae
            });
    }
}
