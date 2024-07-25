// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {Script} from "forge-std/Script.sol";

library HelperConfig {
    struct Config {
        address tokenAddress;
    }

    uint256 constant ETH_MAINNET_CHAIN_ID = 1;
    uint256 constant ETH_SEPOLIA_CHAIN_ID = 11155111;
    uint256 constant LOCAL_CHAIN_ID = 31337;

    function getConfig() internal returns (Config memory) {
        if (block.chainid == ETH_MAINNET_CHAIN_ID) {
            // Mainnet
            return Config({tokenAddress: address(0)});
        } else if (block.chainid == ETH_SEPOLIA_CHAIN_ID) {
            // Sepolia Testnet
            return
                Config({
                    tokenAddress: 0x7daf26D64a62e2e1dB838C84bCAc5bdDb3b5D926
                });
        } else if (block.chainid == LOCAL_CHAIN_ID) {
            // Local development network
            return Config({tokenAddress: deployMockToken()});
        } else {
            revert("Unsupported network");
        }
    }

    function deployMockToken() internal returns (address) {
        // Deploy the mock token here
        ERC20Mock mockToken = new ERC20Mock();
        return address(mockToken);
    }
}
