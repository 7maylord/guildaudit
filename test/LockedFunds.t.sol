// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/LockedFunds.sol";

contract LockedFundsTest is Test {
    LockedFunds lockedFunds;
    address owner = address(0xABCD);
    address attacker = address(0x1234);

    function setUp() public {
        vm.deal(owner, 5 ether);
        vm.deal(attacker, 5 ether);

        vm.prank(owner);
        lockedFunds = new LockedFunds();

        // Fund contract with exactly 1 ether
        vm.prank(owner);
        lockedFunds.deposit{value: 1 ether}();
    }

    function testWithdrawalSucceedsWhenExactBalance() public {
        vm.prank(owner);
        lockedFunds.withdraw(1 ether); // ✅ should pass
    }

    function testWithdrawalFailsWhenBalanceNotExact() public {
        // Send extra funds (attacker sends 0.5 ether)
        vm.prank(attacker);
        lockedFunds.deposit{value: 0.5 ether}();

        // Now balance = 1.5 ether, withdraw(1 ether) should fail
        vm.prank(owner);
        vm.expectRevert("Balance not exactly equal");
        lockedFunds.withdraw(1 ether); // ❌ Fails due to unnecessary check
    }

    function testIntegrationFundsGetLocked() public {
        // Owner deposits 1 ETH
        vm.prank(owner);
        lockedFunds.deposit{value: 1 ether}();

        // Owner plans to withdraw 2 ETH later...
        // But attacker sends extra 0.5 ETH (maybe by mistake or on purpose)
        vm.prank(attacker);
        lockedFunds.deposit{value: 0.5 ether}();

        // Owner tries to withdraw 1 ETH
        vm.prank(owner);
        vm.expectRevert("Balance not exactly equal");
        lockedFunds.withdraw(2 ether);

        // Owner is now stuck — no amount will work unless balance matches exactly
        // Try withdrawing full 2.5 ETH
        vm.prank(owner);
        lockedFunds.withdraw(2.5 ether); // Works only if guessed exactly
    }
}
