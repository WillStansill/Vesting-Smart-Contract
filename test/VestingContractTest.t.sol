// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {VestingContract} from "../src/VestingContract.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract VestingContractTest is Test {
    VestingContract public vestingContract;
    ERC20Mock public token;
    address public owner;
    address public user;
    address public partner;
    address public team;

    function setUp() public {
        owner = address(this);
        user = address(0x1);
        partner = address(0x2);
        team = address(0x3);

        // Deploy ERC20 mock token for testing
        token = new ERC20Mock();

        token.mint(
            address(0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496),
            1000000 * 10 ** 18
        );

        // Deploy VestingContract
        vestingContract = new VestingContract(address(token));

        // Transfer tokens to VestingContract
        token.transfer(address(vestingContract), 1000000 * 10 ** 18);
    }

    function testDeployment() public view {
        assertEq(
            vestingContract.roleAllocations(VestingContract.Role.User),
            50
        );
        assertEq(
            vestingContract.roleAllocations(VestingContract.Role.Partner),
            25
        );
        assertEq(
            vestingContract.roleAllocations(VestingContract.Role.Team),
            25
        );
    }

    function testStartVesting() public {
        vestingContract.startVesting();
        uint256 startTime = vestingContract.startTime();
        assertGt(startTime, 0);
    }

    function testAddBeneficiary() public {
        vestingContract.startVesting();
        vestingContract.addBeneficiary(
            user,
            VestingContract.Role.User,
            50000 * 10 ** 18
        );

        (
            uint256 cliff,
            uint256 duration,
            uint256 allocation,
            uint256 claimed
        ) = vestingContract.schedules(user);
        assertEq(allocation, 50000 * 10 ** 18);
        assertEq(cliff, 30 days * 10);
        assertEq(duration, 365 days * 2);
        assertEq(claimed, 0);
    }

    function testClaimTokens() public {
        vestingContract.startVesting();
        vestingContract.addBeneficiary(
            user,
            VestingContract.Role.User,
            50000 * 10 ** 18
        );

        // Fast forward to after the cliff period
        vm.warp(block.timestamp + (30 days * 10) + 1);

        uint256 elapsedTime = block.timestamp - vestingContract.startTime();
        uint256 vestedAmount = (50000 * 10 ** 18 * elapsedTime) /
            (365 days * 2);
        uint256 claimableAmount = vestedAmount;

        vm.prank(user);

        vestingContract.claimTokens();

        (, , uint256 allocation, uint256 claimed) = vestingContract.schedules(
            user
        );
        assertEq(claimed, claimableAmount);
        assertEq(token.balanceOf(user), claimableAmount);
    }

    function testClaimTokensBeforeCliff() public {
        vestingContract.startVesting();
        vestingContract.addBeneficiary(
            user,
            VestingContract.Role.User,
            50000 * 10 ** 18
        );

        // Fast forward to just before the cliff period
        vm.warp(block.timestamp + (30 days * 10) - 1);

        vm.expectRevert("Cliff period not reached");
        vm.prank(user);
        vestingContract.claimTokens();
    }

    function testDoubleClaimingPrevention() public {
        vestingContract.startVesting();
        vestingContract.addBeneficiary(
            user,
            VestingContract.Role.User,
            50000 * 10 ** 18
        );

        // Fast forward to after the cliff period
        vm.warp(block.timestamp + (30 days * 10) + 1);

        uint256 elapsedTime = block.timestamp - vestingContract.startTime();
        uint256 vestedAmount = (50000 * 10 ** 18 * elapsedTime) /
            (365 days * 2);
        uint256 claimableAmount = vestedAmount;

        vm.prank(user);
        vestingContract.claimTokens();

        (, , uint256 allocation, uint256 claimed) = vestingContract.schedules(
            user
        );
        assertEq(claimed, claimableAmount);
        assertEq(token.balanceOf(user), claimableAmount);

        // Try claiming again without fast forwarding
        vm.prank(user);
        vm.expectRevert("No tokens available for claiming");
        vestingContract.claimTokens();
    }
    function testVestingCalculations() public {
        vestingContract.startVesting();
        vestingContract.addBeneficiary(
            user,
            VestingContract.Role.User,
            50000 * 10 ** 18
        );

        // Fast forward to half the vesting duration (1 year)
        vm.warp(block.timestamp + (365 days));
        uint256 elapsedTime = block.timestamp - vestingContract.startTime();
        uint256 vestedAmount = (50000 * 10 ** 18 * elapsedTime) /
            (365 days * 2);
        uint256 claimableAmount = vestedAmount;

        vm.prank(user);
        vestingContract.claimTokens();

        (, , uint256 allocation, uint256 claimed) = vestingContract.schedules(
            user
        );
        assertEq(claimed, claimableAmount);
        assertEq(token.balanceOf(user), claimableAmount);

        // Fast forward to full vesting duration (another 1 year, total 2 years)
        vm.warp(block.timestamp + (365 days));
        elapsedTime = block.timestamp - vestingContract.startTime();
        vestedAmount = (50000 * 10 ** 18 * elapsedTime) / (365 days * 2);
        claimableAmount = vestedAmount - claimed;

        vm.prank(user);
        vestingContract.claimTokens();

        (, , allocation, claimed) = vestingContract.schedules(user);
        assertEq(claimed, vestedAmount);
        assertEq(token.balanceOf(user), vestedAmount);
    }
}
