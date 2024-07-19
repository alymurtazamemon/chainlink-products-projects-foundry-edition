// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LOCAL_CHAIN_ID, ETH_SEPOLIA_CHAIN_ID} from "helper-config.sol";

contract SubscriptionVRF_HelperConfig is Script {
    // * mock VRF variables
    uint96 private MOCK_BASE_FEE = 100000000000000000; // 0.1 LINK
    uint96 private MOCK_GAS_PRICE_LINK = 1000000000; // in LINK tokens
    // * LINK / ETH price
    int256 private MOCK_WEI_PER_UINT_LINK = 3977213847536709; // LINK/ETH price (at the time of coding)
    uint96 private constant FUND_AMOUNT = 100000000000000000000; // 100 LINK

    NetworkConfig private localNetworkConfig;
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

    function getConfig() external returns (NetworkConfig memory) {
        return getNetworkConfig(block.chainid);
    }

    function getNetworkConfig(
        uint256 chainId
    ) private returns (NetworkConfig memory) {
        if (networkConfigs[chainId].vrfCoordinatorV2_5 != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateLocalBlockchainNetworkConfig();
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
                callbackGasLimit: 500000, // 500,000 gas
                gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae
            });
    }

    function getOrCreateLocalBlockchainNetworkConfig()
        private
        returns (NetworkConfig memory)
    {
        if (localNetworkConfig.vrfCoordinatorV2_5 != address(0)) {
            return localNetworkConfig;
        }

        vm.startBroadcast();

        VRFCoordinatorV2_5Mock vrfMock = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_WEI_PER_UINT_LINK
        );

        /*
         * Note: Due to an arithmetic underflow/overflow error in the SubscriptionAPI contract (lib/chainlink-brownie-contracts/contracts/src/v0.8/vrf/dev/SubscriptionAPI.sol) of the chainlink/chainlink-brownie-contracts dependency, I was unable to call the createSubscription function. After some debugging, I found that the error was caused by the subtraction of blockhash(block.number - 1) in the createSubscription function while generating subId. I removed the -1 from this line, and everything started working as expected. The modified line now looks like this:

         * subId = uint256(keccak256(abi.encodePacked(msg.sender, blockhash(block.number), address(this), currentSubNonce)));
         */

        uint256 subscriptionId = vrfMock.createSubscription();
        vrfMock.fundSubscription(subscriptionId, FUND_AMOUNT);

        vm.stopBroadcast();

        localNetworkConfig = NetworkConfig({
            vrfCoordinatorV2_5: address(vrfMock),
            subscriptionId: subscriptionId,
            callbackGasLimit: 500000, // 500,000 gas
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae
        });

        return localNetworkConfig;
    }
}
