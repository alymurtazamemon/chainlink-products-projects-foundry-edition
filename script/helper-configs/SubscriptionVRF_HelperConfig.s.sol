// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

contract SubscriptionVRF_HelperConfig is Script {
    uint256 private constant ETH_SEPOLIA_CHAIN_ID = 11155111;

    mapping(uint256 chainId => NetworkConfig) private networkConfigs;

    struct NetworkConfig {
        address vrfCoordinatorV2_5; // * VRF V2.5 version
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        bytes32 gasLane;
    }

    error SubscriptionVRF_HelperConfig_InvalidChainId(uint256 chainId);

    constructor() {
        networkConfigs[ETH_SEPOLIA_CHAIN_ID] = getETHSepoliaNetworkConfig();
    }

    function getConfig() external view returns (NetworkConfig memory) {
        return getNetworkConfig(block.chainid);
    }

    function getNetworkConfig(
        uint256 chainId
    ) private view returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinatorV2_5 != address(0)) {
            return networkConfigs[chainId];
        } else {
            revert SubscriptionVRF_HelperConfig_InvalidChainId(chainId);
        }
    }

    function getETHSepoliaNetworkConfig()
        private
        view
        returns (NetworkConfig memory)
    {
        return
            NetworkConfig({
                vrfCoordinatorV2_5: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
                subscriptionId: vm.envUint("SUBSCRIPTION_ID"),
                callbackGasLimit: 40000,
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae
            });
    }
}
