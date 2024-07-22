-include .env

# # Adding .PHONY to a target will prevent Make from confusing the phony target with a file name.
.PHONY: deploy_ConsumerV3_network_anvil run_LatestRoundData_network_anvil deploy_ConsumerV3_network_sepolia run_LatestRoundData_network_sepolia test deploy_SubscriptionVRF_network_anvil run_RequestRandomWords_network_anvil deploy_SubscriptionVRF_network_sepolia run_RequestRandomWords_network_sepolia

# anvil setup

ANVIL_RPC_URL := http://127.0.0.1:8545
ANVIL_PRIVATE_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

ANVIL_NETWORK_ARGS := --rpc-url $(ANVIL_RPC_URL) --private-key $(ANVIL_PRIVATE_KEY) --broadcast

# -> Data Feed Commands

deploy_ConsumerV3_network_anvil:
	@forge script script/deploy/DeployDataConsumerV3.s.sol:DeployDataConsumerV3 $(ANVIL_NETWORK_ARGS)

run_LatestRoundData_network_anvil:
	@forge script script/interaction/DataConsumerV3Interactions.s.sol:LatestRoundData $(ANVIL_NETWORK_ARGS)

test:
	@forge test --mc DataConsumerV3UnitTest

forked_test_network_anvil:
	@forge test --fork-url anvil --match-contract DataConsumerV3ForkedTest

# -> VRF Commands

deploy_SubscriptionVRF_network_anvil:
	@forge script script/deploy/DeploySubscriptionVRFV2_5.s.sol:DeploySubscriptionVRFV2_5 $(ANVIL_NETWORK_ARGS)

run_RequestRandomWords_network_anvil:
	@forge script script/interaction/SubscriptionVRFInteractions.s.sol:RequestRandomWords $(ANVIL_NETWORK_ARGS)

# sepolia setup

SEPOLIA_NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast

# -> Data Feed Commands

deploy_ConsumerV3_network_sepolia:
	@forge script script/deploy/DeployDataConsumerV3.s.sol:DeployDataConsumerV3 $(SEPOLIA_NETWORK_ARGS) --verify --etherscan-api-key $(ETHERSCAN_API_KEY)

run_LatestRoundData_network_sepolia:
	@forge script script/interaction/DataConsumerV3Interactions.s.sol:LatestRoundData $(SEPOLIA_NETWORK_ARGS)

forked_test_network_sepolia:
	@forge test --fork-url sepolia --match-contract DataConsumerV3ForkedTest

# -> VRF Commands

deploy_SubscriptionVRF_network_sepolia:
	@forge script script/deploy/DeploySubscriptionVRFV2_5.s.sol:DeploySubscriptionVRFV2_5 $(SEPOLIA_NETWORK_ARGS) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --legacy

run_RequestRandomWords_network_sepolia:
	@forge script script/interaction/SubscriptionVRFInteractions.s.sol:RequestRandomWords $(SEPOLIA_NETWORK_ARGS) --legacy