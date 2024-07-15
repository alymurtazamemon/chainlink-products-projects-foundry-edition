// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {DeployDataConsumerV3, DataConsumerV3, HelperConfig} from "../../script/deploy/DeployDataConsumerV3.s.sol";

contract DataConsumerV3UnitTest is Test {
    DataConsumerV3 consumer;
    HelperConfig helperConfig;

    function setUp() external {
        DeployDataConsumerV3 deployer = new DeployDataConsumerV3();
        (consumer, helperConfig) = deployer.run();
    }

    function test_version() external {
        assertEq(consumer.getVersion(), 0);
    }

    function test_decimals() external {
        assertEq(consumer.getDecimals(), 8);
    }

    function test_latestRoundData() external {
        assertEq(consumer.getChainlinkDataFeedLatestAnswer(), 2000e8);
    }
}
