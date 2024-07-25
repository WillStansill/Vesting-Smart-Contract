// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {console} from "../lib/forge-std/src/console.sol";

contract VestingContract is Ownable {
    IERC20 public token;
    uint256 public startTime;

    enum Role {
        User,
        Partner,
        Team
    }

    struct VestingSchedule {
        uint256 cliffDuration;
        uint256 vestingDuration;
        uint256 totalAllocation;
        uint256 claimed;
    }

    mapping(address => Role) public beneficiaries;
    mapping(address => VestingSchedule) public schedules;
    mapping(Role => uint256) public roleAllocations;

    event VestingStarted(uint256 startTime);
    event BeneficiaryAdded(
        address beneficiary,
        Role role,
        uint256 totalAllocation
    );
    event TokensClaimed(address beneficiary, uint256 amount);

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
        roleAllocations[Role.User] = 50;
        roleAllocations[Role.Partner] = 25;
        roleAllocations[Role.Team] = 25;
    }

    function startVesting() external onlyOwner {
        require(startTime == 0, "Vesting already started");
        startTime = block.timestamp;
        emit VestingStarted(startTime);
    }

    function addBeneficiary(
        address _beneficiary,
        Role _role,
        uint256 _totalAllocation
    ) external onlyOwner {
        require(
            schedules[_beneficiary].totalAllocation == 0,
            "Beneficiary already added"
        );
        beneficiaries[_beneficiary] = _role;

        uint256 cliffDuration;
        uint256 vestingDuration;

        if (_role == Role.User) {
            cliffDuration = 30 days * 10; // 10 months
            vestingDuration = 365 days * 2; // 2 years
        } else if (_role == Role.Partner || _role == Role.Team) {
            cliffDuration = 30 days * 2; // 2 months
            vestingDuration = 365 days; // 1 year
        }

        schedules[_beneficiary] = VestingSchedule({
            cliffDuration: cliffDuration,
            vestingDuration: vestingDuration,
            totalAllocation: _totalAllocation,
            claimed: 0
        });

        emit BeneficiaryAdded(_beneficiary, _role, _totalAllocation);
    }

    function claimTokens() external {
        require(startTime > 0, "Vesting not started");

        VestingSchedule storage schedule = schedules[msg.sender];
        require(schedule.totalAllocation > 0, "No tokens allocated");

        uint256 elapsedTime = block.timestamp - startTime;
        require(
            elapsedTime > schedule.cliffDuration,
            "Cliff period not reached"
        );

        uint256 vestedAmount = (schedule.totalAllocation * elapsedTime) /
            schedule.vestingDuration;
        uint256 claimableAmount = vestedAmount - schedule.claimed;

        require(claimableAmount > 0, "No tokens available for claiming");

        schedule.claimed += claimableAmount;
        token.transfer(msg.sender, claimableAmount);

        emit TokensClaimed(msg.sender, claimableAmount);
    }
}
