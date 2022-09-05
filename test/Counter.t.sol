// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/mock/MockDelegatable.sol";

contract DelegateTest is Test {
    MockDelegatable public D;

    address iOwner;
    address gotDelegation;
    address third;

    string BASE_AUTH = "0x0000000000000000000000000000000000000000000000000000000000000000";
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 pvk1;
    uint256 pvk2;
    uint256 pvk3;

    struct Transaction {
        address to;
        uint256 gasLimit;
        bytes data;
    }

    struct Invocation {
        Transaction transaction;
        SignedDelegation[] authority;
    }

    struct SignedInvocation {
        Invocations invocations;
        bytes signature;
    }

    struct Delegation {
        address delegate;
        bytes32 authority;
        Caveat[] caveats;
    }

    struct Caveat {
        address enforcer;
        bytes terms;
    }

    struct SignedDelegation {
        Delegation delegation;
        bytes signature;
    }

    function setUp() public {
        uint256 pvk1 = vm.deriveKey(mnemonic, 1);
        uint256 pvk2 = vm.deriveKey(mnemonic, 6);
        uint256 pvk3 = vm.deriveKey(mnemonic, 9);

        iOwner = vm.addr(pvk1);
        gotDelegation = vm.addr(pvk2);
        third = vm.addr(pvk3);

        vm.prank(iOwner);
        D = new MockDelegatable("DDD");
    }

    function sTa(string memory s_) public returns (address) {
        return address(bytes20(bytes(s_)));
    }

    function testFunctionNoDelegation() public {
        vm.startPrank(iOwner);
        assertTrue(sTa(D.purpose()) == sTa("What is my purpose?"));
        D.setPurpose("New Purpose");
        assertTrue(sTa(D.purpose()) == sTa("New Purpose"));
        vm.stopPrank();

        vm.prank(gotDelegation);
        vm.expectRevert("Ownable: caller is not the owner");
        D.setPurpose("I want my purpose to be your purpose!");

        vm.prank(iOwner);
    }
}
