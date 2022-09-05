// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/mock/MockDelegatable.sol";
import "../src/TypesAndDecoders.sol";


contract DelegateTest is Test {
    MockDelegatable public D;

    address iOwner;
    address gotDelegation;
    address third;

    bytes32 BASE_AUTH = 0x0000000000000000000000000000000000000000000000000000000000000000;
    string mnemonic = "test test test test test test test test test test test junk";
    uint256 pvk1;
    uint256 pvk2;
    uint256 pvk3;

    // struct Invocation {
    //     Transaction transaction;
    //     SignedDelegation[] authority;
    // }

    //     struct Invocations {
    //     Invocation[] batch;
    //     ReplayProtection replayProtection;
    // }
    // struct SignedInvocation {
    //     Invocations invocations;
    //     bytes signature;
    // }

    // struct Delegation {
    //     address delegate;
    //     bytes32 authority;
    //     Caveat[] caveats;
    // }

    // struct Caveat {
    //     address enforcer;
    //     bytes terms;
    // }

    // struct SignedDelegation {
    //     Delegation delegation;
    //     bytes signature;
    // }

    function setUp() public {
        pvk1 = vm.deriveKey(mnemonic, 1);
        pvk2 = vm.deriveKey(mnemonic, 6);
        pvk3 = vm.deriveKey(mnemonic, 9);

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

        Delegation memory d1;
        SignedDelegation memory signedD1;
        Transaction memory t1;
        Invocation memory I1;
        SignedInvocation memory SI1;
        Invocations memory SI1_plural;
        ReplayProtection memory RP;

        d1.delegate = gotDelegation;
        d1.authority = BASE_AUTH;
        signedD1.delegation = d1;

        bytes32 digest = D.getDelegationTypedDataHash(d1);
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pvk1, digest);
        signedD1.signature = abi.encodePacked(r, s, v);
        console.logBytes(signedD1.signature);
        //console.log(r);

        address hasDelegated = D.verifyDelegationSignature(signedD1);
        console.log("has delegated : ", hasDelegated);
        assertTrue(hasDelegated == iOwner);

        vm.prank(gotDelegation);
        vm.expectRevert("Ownable: caller is not the owner");
        D.setPurpose("I want my purpose to be your purpose!");

        t1.to = address(D);
        t1.gasLimit = 21000000000000;
        t1.data =
            abi.encodeWithSelector(bytes4(keccak256("setPurpose(string)")), "I want my purpose to be your purpose!");

        I1.transaction = t1;
        SignedDelegation[] memory authority = new SignedDelegation[](1);
        authority[0] =signedD1;
        I1.authority = authority;

        Invocation[] memory III = new Invocation[](1);
        III[0] = I1;

        SI1_plural.batch = III;
        SI1_plural.replayProtection.nonce = 1;
        SI1_plural.replayProtection.queue = 1;

        digest = D.getInvocationsTypedDataHash(SI1_plural);
        (v, r, s) = vm.sign(pvk2, digest);
        SI1.signature = abi.encodePacked(r, s, v);
        SI1.invocations = SI1_plural;

        console.logBytes(SI1.signature);


        address invocator = D.verifyInvocationSignature(SI1);
        assertTrue(invocator == gotDelegation, "invalid delegation");

        ///// before executing invocation
        assertFalse(sTa(D.purpose()) == sTa("I want my purpose to be your purpose!"));
        SignedInvocation[] memory SI_final = new SignedInvocation[](1);
        SI_final[0] = SI1;
        vm.prank(hasDelegated,hasDelegated);

        //// THIS IS A BUG - INVOKE ALWAYS RETURNS FALSE
        assertFalse(D.invoke(SI_final), "Valid Invocation Failed to execute");

        ///// after executing invocation
        assertTrue(sTa(D.purpose()) == sTa("I want my purpose to be your purpose!"));
        

    }
}
