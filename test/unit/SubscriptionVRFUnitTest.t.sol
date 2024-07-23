// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {LOCAL_CHAIN_ID} from "helper-config.sol";
import {DeploySubscriptionVRFV2_5} from "../../script/deploy/DeploySubscriptionVRFV2_5.s.sol";
import {SubscriptionVRF_HelperConfig} from "../../script/helper-configs/SubscriptionVRF_HelperConfig.s.sol";
import {SubscriptionBasedVRFConsumer} from "../../src/SubscriptionBasedVRFConsumer.sol";

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract SubscriptionVRFUnitTest is Test {
    SubscriptionBasedVRFConsumer vrfConsumer;
    SubscriptionVRF_HelperConfig helperConfig;
    VRFCoordinatorV2_5Mock vrfCoordinatorV2_5;

    event RequestSent(uint256 requestId, uint32 numWords);

    error SubscriptionVRFUnitTest__NotALocalChain(uint256 chainId);

    modifier onlyLocalChain() {
        if (block.chainid != LOCAL_CHAIN_ID) {
            revert SubscriptionVRFUnitTest__NotALocalChain(block.chainid);
        }
        _;
    }

    function setUp() external onlyLocalChain {
        address vrfCoordinatorV2_5Address;

        DeploySubscriptionVRFV2_5 deployer = new DeploySubscriptionVRFV2_5();
        (vrfConsumer, helperConfig, vrfCoordinatorV2_5Address) = deployer.run();
        vrfCoordinatorV2_5 = VRFCoordinatorV2_5Mock(vrfCoordinatorV2_5Address);
    }

    function test_onlyOnwerCanCallRequestRandomNumber() external {
        vm.expectRevert(bytes("Only callable by owner"));
        vrfConsumer.requestRandomNumber();
    }

    function test_requestRandomNumber() external {
        vm.prank(msg.sender);

        // * expect this event to be emitted after calling requestRandomNumber
        vm.expectEmit(true, true, false, true);
        emit RequestSent(1, 1);

        uint256 requestId = vrfConsumer.requestRandomNumber();

        (bool fulfilled, ) = vrfConsumer.getRequestStatus(requestId);

        assertEq(fulfilled, false);
        assertEq(vrfConsumer.getRequestIds()[0], requestId);
        assertEq(vrfConsumer.getLastRequestId(), requestId);
    }

    function test_fulfillRandomWords_RevertIfRequestIdDoesntExist() external {
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);

        vrfCoordinatorV2_5.fulfillRandomWords(1, address(vrfConsumer));
    }

    function test_fulfillRandomWords() external {
        vm.startPrank(msg.sender);

        uint256 requestId = vrfConsumer.requestRandomNumber();

        vm.stopPrank();

        vrfCoordinatorV2_5.fulfillRandomWords(requestId, address(vrfConsumer));

        (bool fulfilled, uint256[] memory randomWords) = vrfConsumer
            .getRequestStatus(requestId);

        assertEq(fulfilled, true);
        assertEq(randomWords.length, 1);
    }
}
