// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "./interfaces/IERC20.sol";
import {ReentrancyGuard} from "./utils/ReentrancyGuard.sol";

/// @title FlowStream - Decentralized Payment Streaming Protocol
/// @notice Enables continuous, per-second token streaming between addresses
/// @dev Supports ERC-20 token streams with start, cancel, and withdraw operations
contract FlowStream is ReentrancyGuard {
    // ──────────────────────────── Types ────────────────────────────

    struct Stream {
        address sender;
        address recipient;
        address token;
        uint256 deposit;
        uint256 ratePerSecond;
        uint256 startTime;
        uint256 stopTime;
        uint256 withdrawn;
        bool active;
    }

    // ──────────────────────────── State ────────────────────────────

    uint256 public nextStreamId = 1;
    mapping(uint256 => Stream) public streams;

    // ──────────────────────────── Events ───────────────────────────

    event StreamCreated(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        address token,
        uint256 deposit,
        uint256 ratePerSecond,
        uint256 startTime,
        uint256 stopTime
    );

    event StreamCancelled(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 senderBalance,
        uint256 recipientBalance
    );

    event Withdrawal(
        uint256 indexed streamId,
        address indexed recipient,
        uint256 amount
    );

    // ──────────────────────────── Errors ───────────────────────────

    error InvalidRecipient();
    error InvalidDeposit();
    error InvalidTimeRange();
    error DepositNotDivisible();
    error StreamNotActive();
    error Unauthorized();
    error NothingToWithdraw();
    error TransferFailed();

    // ──────────────────────────── Core Logic ───────────────────────

    /// @notice Create a new payment stream
    /// @param recipient Address receiving the streamed tokens
    /// @param token ERC-20 token address
    /// @param deposit Total amount to be streamed
    /// @param startTime Unix timestamp when streaming begins
    /// @param stopTime Unix timestamp when streaming ends
    /// @return streamId The ID of the newly created stream
    function createStream(
        address recipient,
        address token,
        uint256 deposit,
        uint256 startTime,
        uint256 stopTime
    ) external nonReentrant returns (uint256 streamId) {
        if (recipient == address(0) || recipient == msg.sender) revert InvalidRecipient();
        if (deposit == 0) revert InvalidDeposit();
        if (stopTime <= startTime || startTime < block.timestamp) revert InvalidTimeRange();

        uint256 duration = stopTime - startTime;
        if (deposit % duration != 0) revert DepositNotDivisible();

        uint256 ratePerSecond = deposit / duration;

        bool success = IERC20(token).transferFrom(msg.sender, address(this), deposit);
        if (!success) revert TransferFailed();

        streamId = nextStreamId++;

        streams[streamId] = Stream({
            sender: msg.sender,
            recipient: recipient,
            token: token,
            deposit: deposit,
            ratePerSecond: ratePerSecond,
            startTime: startTime,
            stopTime: stopTime,
            withdrawn: 0,
            active: true
        });

        emit StreamCreated(
            streamId,
            msg.sender,
            recipient,
            token,
            deposit,
            ratePerSecond,
            startTime,
            stopTime
        );
    }

    /// @notice Withdraw accrued tokens from a stream
    /// @param streamId The stream to withdraw from
    /// @param amount The amount to withdraw
    function withdraw(uint256 streamId, uint256 amount) external nonReentrant {
        Stream storage stream = streams[streamId];
        if (!stream.active) revert StreamNotActive();
        if (msg.sender != stream.recipient) revert Unauthorized();

        uint256 available = _recipientBalance(stream);
        if (amount == 0 || amount > available) revert NothingToWithdraw();

        stream.withdrawn += amount;

        bool success = IERC20(stream.token).transfer(stream.recipient, amount);
        if (!success) revert TransferFailed();

        emit Withdrawal(streamId, stream.recipient, amount);
    }

    /// @notice Cancel an active stream; splits remaining funds proportionally
    /// @param streamId The stream to cancel
    function cancelStream(uint256 streamId) external nonReentrant {
        Stream storage stream = streams[streamId];
        if (!stream.active) revert StreamNotActive();
        if (msg.sender != stream.sender && msg.sender != stream.recipient) revert Unauthorized();

        stream.active = false;

        uint256 recipientBal = _recipientBalance(stream);
        uint256 senderBal = stream.deposit - stream.withdrawn - recipientBal;

        if (recipientBal > 0) {
            bool s1 = IERC20(stream.token).transfer(stream.recipient, recipientBal);
            if (!s1) revert TransferFailed();
        }
        if (senderBal > 0) {
            bool s2 = IERC20(stream.token).transfer(stream.sender, senderBal);
            if (!s2) revert TransferFailed();
        }

        emit StreamCancelled(streamId, stream.sender, stream.recipient, senderBal, recipientBal);
    }

    // ──────────────────────────── View Functions ──────────────────

    /// @notice Get the balance available for the recipient to withdraw
    function balanceOf(uint256 streamId) external view returns (uint256) {
        Stream storage stream = streams[streamId];
        if (!stream.active) return 0;
        return _recipientBalance(stream);
    }

    /// @notice Get full stream details
    function getStream(uint256 streamId) external view returns (Stream memory) {
        return streams[streamId];
    }

    // ──────────────────────────── Internal ─────────────────────────

    function _recipientBalance(Stream storage stream) internal view returns (uint256) {
        uint256 currentTime = block.timestamp;
        if (currentTime <= stream.startTime) return 0;
        if (currentTime >= stream.stopTime) {
            return stream.deposit - stream.withdrawn;
        }
        uint256 elapsed = currentTime - stream.startTime;
        uint256 earned = elapsed * stream.ratePerSecond;
        return earned - stream.withdrawn;
    }
}
