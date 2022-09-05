// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/mock/MockDelegatable.sol";

contract DelegateTest is Test {
    MockDelegatable public D;

    address iOwner;
    address gotDelegation;

    function setUp() public {
       
       iOwner = address(16);
       gotDelegation = address(256);
       D = new MockDelegatable("DDD");
    }

    function sTa(string memory s_) public returns (address){
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


    }

}
