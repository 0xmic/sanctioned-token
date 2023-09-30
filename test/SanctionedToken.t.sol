// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {DeploySanctionedToken} from "../script/DeploySanctionedToken.s.sol";
import {SanctionedToken} from "../src/SanctionedToken.sol";

contract SanctionsTest is StdCheats, Test {
    uint256 BOB_STARTING_AMOUNT = 100 ether;

    SanctionedToken public sanctionedToken;
    DeploySanctionedToken public deployer;
    address public deployerAddress;
    address alice;
    address bob;

    function setUp() public {
        deployer = new DeploySanctionedToken();
        sanctionedToken = deployer.run();

        alice = makeAddr("alice");
        bob = makeAddr("bob");

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
        sanctionedToken.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function test_InitialSupply() public {
        assertEq(sanctionedToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function test_BobBalance() public {
        assertEq(sanctionedToken.balanceOf(bob), BOB_STARTING_AMOUNT);
    }
    
    function test_BanAddress() public {
        vm.prank(deployerAddress);
        sanctionedToken.banAddress(bob);
        assertEq(sanctionedToken.isBanned(bob), true);
    }

    function test_UnbanAddress() public {
        vm.startPrank(deployerAddress);
        sanctionedToken.banAddress(bob);
        sanctionedToken.unbanAddress(bob);
        vm.stopPrank();
        assertEq(sanctionedToken.isBanned(bob), false);
    }

    // TODO: Add tests for events, isBanned(), fail cases
}