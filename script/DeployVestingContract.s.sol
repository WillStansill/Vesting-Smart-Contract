// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {VestingContract} from "../src/VestingContract.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployVestingContract is Script {
    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Get configuration based on the network
        HelperConfig.Config memory config = HelperConfig.getConfig();

        // Deploy VestingContract with the configured token address
        VestingContract vestingContract = new VestingContract(
            config.tokenAddress
        );

        console.log("VestingContract deployed at:", address(vestingContract));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
