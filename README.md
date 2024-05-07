# Chainlink Products Projects - Foundry Edition

This repository contains the implementation of Chainlink products. It demonstrates deployment, interactions, and testing of all these products.

# Getting Started

## Requirements

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [Foundry](https://book.getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

## Quickstart

```bash
git clone https://github.com/alymurtazamemon/chainlink-products-projects-foundry-edition.git
cd chainlink-products-projects-foundry-edition
forge build
```

## Usage

`Note`: Due to the extensive sequence of foundry commands used in this project, it utilizes the [GNU make](https://www.gnu.org/software/make/manual/make.html) utility. You can install it from the provided link. If you prefer to solely utilize foundry commands and not use GNU make, you can simply copy and paste the commands from the Makefile.

`Note`: For the local Anvil chain, the `RPC URL` and `Private key` are set in the `Makefile`. For the rest of the networks, you need to create an `.env` file and add the RPC URL and Private key for those networks. Make sure the environment variable names match those used in the Makefile. 

`Note`: This project utilizes the [foundry-devops](https://github.com/Cyfrin/foundry-devops) dependency, which retrieves the most recent deployment from a specified environment in Foundry. This enables scripting based on previous deployments in Solidity. If you are running an Anvil node, ensure that the node is open so you can use previously deployed contracts for scripting. If you close it, you will need to redeploy contracts in order to interact with them.

### DataConsumerV3

- The `DataConsumerV3` contract requires a price feed address in the constructor. The configurations for Anvil and Sepolia chains are set in the `HelperConfig.sol` file. If you want to use it on any other chain, first add the network configurations to this file.

#### Anvil

- `Deploy`: To deploy on the Anvil chain, you need to open an Anvil node and then run the command;
  
  ```
  make deploy_ConsumerV3_network_anvil
  ```
- `Interact`: Get the latest price using the command;
  ```
  make run_LatestRoundData_network_anvil
  ```
- `Test (Unit)`: Run the unit test using command;
  ```
  make test
  ```
- `Test (forked)`: Run the test on the forked Anvil network. Make sure set the `rpc_endpoints` in the `foundry.toml` file.
  ```
  make forked_test_network_anvil
  ```

#### Sepolia

- `Deploy`: To deploy on the Sepolia chain, run the command;
  
  ```
  make deploy_ConsumerV3_network_sepolia
  ```
- `Interact`: Get the latest price using the command;
  ```
  make run_LatestRoundData_network_sepolia
  ```
- `Test (forked)`: Run the test on the forked Sepolia network. Make sure set the `rpc_endpoints` in the `foundry.toml` file.
  ```
  make forked_test_network_sepolia
  ```