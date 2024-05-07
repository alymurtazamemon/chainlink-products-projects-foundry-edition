// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";

import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {DataConsumerV3} from "../../src/DataConsumerV3.sol";
import {console} from "forge-std/console.sol";

contract DataConsumerV3ForkedTest is Test {
    DataConsumerV3 private consumer;

    function setUp() external {
        address latestContractAddress = DevOpsTools.get_most_recent_deployment(
            "DataConsumerV3",
            block.chainid
        );

        consumer = DataConsumerV3(latestContractAddress);
    }

    function test_version() external {
        if (block.chainid == 31337) {
            assertEq(consumer.getVersion(), 0);
        } else {
            assertEq(consumer.getVersion(), 4);
        }
    }
}
