// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// * imports
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

// * errors
error SubscriptionBasedVRFConsumer__RequestIdNotFound(uint256 requestId);

contract SubscriptionBasedVRFConsumer is VRFConsumerBaseV2Plus {
    // * state variables

    uint16 private constant REQUEST_CONFIRMATIONS = 3;

    uint32 private constant NUM_WORDS = 1;
    uint32 private s_callbackGasLimit;

    uint256 private s_subscriptionId;
    uint256[] private s_requestIds;
    uint256 private s_lastRequestId;

    bytes32 private s_gasLane;

    struct RequestStatus {
        bool fulfilled; // * whether the request has been successfully fulfilled
        bool exists; // * whether a requestId exists
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests; // * requestId --> requestStatus

    // * events

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    // * constructor
    /**
     * Network: Ethereum Sepolia
     * VRF Coordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B
     */
    constructor(
        address vrfCoordinatorV2_5, // * VRF V2.5 version
        uint256 subscriptionId,
        uint32 callbackGasLimit,
        bytes32 gasLane
    ) VRFConsumerBaseV2Plus(vrfCoordinatorV2_5) {
        s_subscriptionId = subscriptionId;
        s_callbackGasLimit = callbackGasLimit;
        s_gasLane = gasLane;
    }

    // * functions

    function requestRandomNumber()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_gasLane,
                subId: s_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: s_callbackGasLimit,
                numWords: NUM_WORDS,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });

        s_requestIds.push(requestId);
        s_lastRequestId = requestId;

        emit RequestSent(requestId, NUM_WORDS);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal virtual override {
        if (!s_requests[requestId].exists) {
            revert SubscriptionBasedVRFConsumer__RequestIdNotFound(requestId);
        }

        s_requests[requestId].fulfilled = true;
        s_requests[requestId].randomWords = randomWords;
        emit RequestFulfilled(requestId, randomWords);
    }

    function updateCallbackGasLimit(
        uint32 newCallbackGasLimit
    ) external onlyOwner {
        s_callbackGasLimit = newCallbackGasLimit;
    }

    function updateSubscriptionId(
        uint256 newSubscriptionId
    ) external onlyOwner {
        s_subscriptionId = newSubscriptionId;
    }

    function updateGasLane(bytes32 newGasLane) external onlyOwner {
        s_gasLane = newGasLane;
    }

    // * view & pure functions

    function getRequestStatus(
        uint256 requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        if (!s_requests[requestId].exists) {
            revert SubscriptionBasedVRFConsumer__RequestIdNotFound(requestId);
        }
        RequestStatus memory request = s_requests[requestId];
        return (request.fulfilled, request.randomWords);
    }

    function getVRFCoordinatorV2_5Address() external view returns (address) {
        return address(s_vrfCoordinator);
    }

    function getCallbackGasLimit() external view returns (uint256) {
        return s_callbackGasLimit;
    }

    function getRequestIds() external view returns (uint256[] memory) {
        return s_requestIds;
    }

    function getLastRequestId() external view returns (uint256) {
        return s_lastRequestId;
    }

    function getNumWords() external pure returns (uint256) {
        return NUM_WORDS;
    }

    function getRequiredConfirmations() external pure returns (uint256) {
        return REQUEST_CONFIRMATIONS;
    }
}
