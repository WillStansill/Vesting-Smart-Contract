Vesting Contract
Overview
The Vesting Contract project implements a vesting mechanism using smart contracts. It allows the deployment of a vesting contract that can handle different roles (User, Partner, Team) with specific vesting schedules. The project includes a VestingContract smart contract, test cases, deployment scripts, and a helper configuration for different environments.

Project Structure
src/: Contains the main smart contracts.
VestingContract.sol: The main vesting contract.
script/: Contains deployment scripts and helper configurations.
DeployVestingContract.s.sol: Script to deploy the VestingContract.
HelperConfig.s.sol: Provides network-specific configurations and mock token deployment.
test/: Contains test cases for the VestingContract.
VestingContractTest.sol: Tests for the vesting contract.
lib/: Contains external libraries (e.g., OpenZeppelin contracts, Forge libraries).
Makefile: Build and deployment automation file.
forge.config.toml: Foundry configuration file.
Getting Started
Prerequisites
Node.js and npm
Foundry (Forge)
Git
Installation
Clone the repository:

bash
git clone <repository-url>
cd <repository-directory>
Install the necessary dependencies:

bash
npm install
Install Foundry if you haven't already:

bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
Configuration
The HelperConfig library provides configurations for different networks:

Mainnet: Placeholder for the mainnet token address.
Sepolia: Uses a predefined token address.
Local: Deploys a mock ERC20 token for local development.
You can configure these settings as needed.

Testing
To run the tests for the VestingContract, use the following command:

bash
make test
The tests will validate the contract’s functionality including vesting schedules, token claims, and edge cases.

Deployment
Local Deployment
To deploy the VestingContract on a local network:

bash
make deploy-local
Sepolia Testnet Deployment
To deploy the VestingContract on the Sepolia testnet:

bash
make deploy-sepolia
Mainnet Deployment
To deploy the VestingContract on the Ethereum mainnet:

bash
make deploy-mainnet
You can also use the deploy target with the network variable:

bash
make deploy network=local
make deploy network=sepolia
make deploy network=mainnet
Usage
Start Vesting: Call startVesting() to initialize the vesting period.
Add Beneficiary: Use addBeneficiary(address _beneficiary, Role _role, uint256 _totalAllocation) to add beneficiaries with their respective allocations.
Claim Tokens: Beneficiaries can call claimTokens() to claim their vested tokens once the cliff period is over.
Contract Details
VestingContract.sol: Implements the vesting logic with role-based allocations and token claiming.
VestingContractTest.sol: Provides unit tests for the vesting contract.
Example Usage
Here's a brief example of how to interact with the VestingContract:

solidity
// Deploying the contract
VestingContract vestingContract = new VestingContract(tokenAddress);

// Starting the vesting
vestingContract.startVesting();

// Adding a beneficiary
vestingContract.addBeneficiary(userAddress, VestingContract.Role.User, 1000 * 10 ** 18);

// Claiming tokens
vestingContract.claimTokens();
Troubleshooting
Deployment Issues: Ensure the correct network is selected and the token address is configured properly.
Test Failures: Verify the contract logic and test environment setup. Check for issues with the mock token or time manipulation in tests.
Contributing
Feel free to submit issues or pull requests. Please ensure that all tests pass before submitting changes.

License
This project is licensed under the MIT License. See the LICENSE file for details.
