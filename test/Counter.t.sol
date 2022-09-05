// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/mock/MockDelegatable.sol";

contract DelegateTest is Test {
    MockDelegatable public D;
    function setUp() public {
       D = new MockDelegatable("DDD");

    }

    function testIncrement() public {
        1+1;
    }

}
