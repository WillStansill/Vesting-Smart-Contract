# Define network IDs and configurations
LOCAL_CHAIN_ID=31337
SEPOLIA_CHAIN_ID=11155111
MAINNET_CHAIN_ID=1

# Commands
install:
	npm install

test:
	forge test

deploy-local:
	forge script script/DeployVestingContract.s.sol:DeployVestingContract --network local

deploy-sepolia:
	forge script script/DeployVestingContract.s.sol:DeployVestingContract --network sepolia

deploy-mainnet:
	forge script script/DeployVestingContract.s.sol:DeployVestingContract --network mainnet

migrate:
	@echo "Migrating contracts..."

clean:
	forge clean

# Default target
all: install test

# Use the network environment variable to select the target
deploy:
ifeq ($(network),local)
	forge script script/DeployVestingContract.s.sol:DeployVestingContract --network local
else ifeq ($(network),sepolia)
	forge script script/DeployVestingContract.s.sol:DeployVestingContract --network sepolia
else ifeq ($(network),mainnet)
	forge script script/DeployVestingContract.s.sol:DeployVestingContract --network mainnet
else
	$(error "Invalid network specified. Use 'local', 'sepolia', or 'mainnet'.")
endif

.PHONY: install test deploy-local deploy-sepolia deploy-mainnet migrate clean all deploy
