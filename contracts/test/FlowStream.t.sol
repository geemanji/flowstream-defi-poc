// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {FlowStream} from "../src/FlowStream.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract FlowStreamTest is Test {
    FlowStream public flowStream;
    MockERC20 public token;

    address public sender = address(0x1);
    address public recipient = address(0x2);

    uint256 public constant DEPOSIT = 3600 ether; // 1 ETH per second for 1 hour
    uint256 public constant DURATION = 3600; // 1 hour

    function setUp() public {
        flowStream = new FlowStream();
        token = new MockERC20("Test Token", "TST");

        token.mint(sender, 100_000 ether);
        vm.prank(sender);
        token.approve(address(flowStream), type(uint256).max);
    }

    function _createDefaultStream() internal returns (uint256) {
        uint256 start = block.timestamp + 1;
        uint256 stop = start + DURATION;
        vm.prank(sender);
        return flowStream.createStream(recipient, address(token), DEPOSIT, start, stop);
    }

    // ──────────────── Create Stream Tests ────────────────

    function test_createStream() public {
        uint256 streamId = _createDefaultStream();
        assertEq(streamId, 1);

        FlowStream.Stream memory s = flowStream.getStream(streamId);
        assertEq(s.sender, sender);
        assertEq(s.recipient, recipient);
        assertEq(s.deposit, DEPOSIT);
        assertEq(s.ratePerSecond, DEPOSIT / DURATION);
        assertTrue(s.active);
    }

    function test_createStream_transfersTokens() public {
        uint256 balBefore = token.balanceOf(sender);
        _createDefaultStream();
        uint256 balAfter = token.balanceOf(sender);
        assertEq(balBefore - balAfter, DEPOSIT);
    }

    function test_revert_createStream_zeroRecipient() public {
        vm.prank(sender);
        vm.expectRevert(FlowStream.InvalidRecipient.selector);
        flowStream.createStream(address(0), address(token), DEPOSIT, block.timestamp + 1, block.timestamp + 3601);
    }

    function test_revert_createStream_selfRecipient() public {
        vm.prank(sender);
        vm.expectRevert(FlowStream.InvalidRecipient.selector);
        flowStream.createStream(sender, address(token), DEPOSIT, block.timestamp + 1, block.timestamp + 3601);
    }

    function test_revert_createStream_zeroDeposit() public {
        vm.prank(sender);
        vm.expectRevert(FlowStream.InvalidDeposit.selector);
        flowStream.createStream(recipient, address(token), 0, block.timestamp + 1, block.timestamp + 3601);
    }

    function test_revert_createStream_invalidTimeRange() public {
        vm.prank(sender);
        vm.expectRevert(FlowStream.InvalidTimeRange.selector);
        flowStream.createStream(recipient, address(token), DEPOSIT, block.timestamp + 3601, block.timestamp + 1);
    }

    // ──────────────── Withdraw Tests ────────────────

    function test_withdraw_partial() public {
        uint256 streamId = _createDefaultStream();
        uint256 start = block.timestamp + 1;

        // Warp 1800 seconds into the stream (half)
        vm.warp(start + 1800);

        uint256 expectedBalance = 1800 * (DEPOSIT / DURATION);
        assertEq(flowStream.balanceOf(streamId), expectedBalance);

        vm.prank(recipient);
        flowStream.withdraw(streamId, expectedBalance);

        assertEq(token.balanceOf(recipient), expectedBalance);
    }

    function test_withdraw_full() public {
        uint256 streamId = _createDefaultStream();
        uint256 start = block.timestamp + 1;

        // Warp past the end
        vm.warp(start + DURATION + 1);

        assertEq(flowStream.balanceOf(streamId), DEPOSIT);

        vm.prank(recipient);
        flowStream.withdraw(streamId, DEPOSIT);

        assertEq(token.balanceOf(recipient), DEPOSIT);
    }

    function test_revert_withdraw_unauthorized() public {
        uint256 streamId = _createDefaultStream();
        vm.warp(block.timestamp + 1 + 1800);

        vm.prank(sender); // sender cannot withdraw
        vm.expectRevert(FlowStream.Unauthorized.selector);
        flowStream.withdraw(streamId, 1 ether);
    }

    function test_revert_withdraw_exceeds_balance() public {
        uint256 streamId = _createDefaultStream();
        vm.warp(block.timestamp + 1 + 100);

        uint256 available = flowStream.balanceOf(streamId);

        vm.prank(recipient);
        vm.expectRevert(FlowStream.NothingToWithdraw.selector);
        flowStream.withdraw(streamId, available + 1);
    }

    // ──────────────── Cancel Stream Tests ────────────────

    function test_cancelStream_bySender() public {
        uint256 streamId = _createDefaultStream();
        uint256 start = block.timestamp + 1;

        vm.warp(start + 1800); // halfway

        uint256 recipientBal = flowStream.balanceOf(streamId);
        uint256 senderBalBefore = token.balanceOf(sender);

        vm.prank(sender);
        flowStream.cancelStream(streamId);

        FlowStream.Stream memory s = flowStream.getStream(streamId);
        assertFalse(s.active);

        assertEq(token.balanceOf(recipient), recipientBal);
        assertEq(token.balanceOf(sender) - senderBalBefore, DEPOSIT - recipientBal);
    }

    function test_cancelStream_byRecipient() public {
        uint256 streamId = _createDefaultStream();
        vm.warp(block.timestamp + 1 + 1800);

        vm.prank(recipient);
        flowStream.cancelStream(streamId);

        FlowStream.Stream memory s = flowStream.getStream(streamId);
        assertFalse(s.active);
    }

    function test_revert_cancelStream_notActive() public {
        uint256 streamId = _createDefaultStream();
        vm.warp(block.timestamp + 1 + 1800);

        vm.prank(sender);
        flowStream.cancelStream(streamId);

        vm.prank(sender);
        vm.expectRevert(FlowStream.StreamNotActive.selector);
        flowStream.cancelStream(streamId);
    }

    function test_revert_cancelStream_unauthorized() public {
        uint256 streamId = _createDefaultStream();
        vm.warp(block.timestamp + 1 + 100);

        address rando = address(0x999);
        vm.prank(rando);
        vm.expectRevert(FlowStream.Unauthorized.selector);
        flowStream.cancelStream(streamId);
    }

    // ──────────────── Balance View Tests ────────────────

    function test_balanceOf_beforeStart() public {
        uint256 streamId = _createDefaultStream();
        // Don't warp, still before start
        assertEq(flowStream.balanceOf(streamId), 0);
    }

    function test_balanceOf_afterCancel() public {
        uint256 streamId = _createDefaultStream();
        vm.warp(block.timestamp + 1 + 100);

        vm.prank(sender);
        flowStream.cancelStream(streamId);

        assertEq(flowStream.balanceOf(streamId), 0);
    }

    function test_nextStreamId_increments() public {
        _createDefaultStream();
        _createDefaultStream();
        assertEq(flowStream.nextStreamId(), 3);
    }
}
