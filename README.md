# Merkle Tree Token Airdrop (WIP)

This repository implements a token airdrop mechanism using a Merkle tree for authentication of claimers. The Merkle tree allows for efficient and secure verification that a given address and amount are eligible for the airdrop, without revealing the entire list of claimers on-chain.

> **⚠️ Work in Progress:**  
> This project is under active development. The code and documentation are subject to change. Use at your own risk.

## Overview

- **Airdrop Contract:**  
  The smart contract (`MerkleAirdrop.sol`) allows eligible users to claim tokens by providing a valid Merkle proof.
- **Merkle Tree Generation:**  
  Scripts are provided to generate the Merkle tree and corresponding proofs from a list of eligible addresses and amounts.
- **Testing:**  
  Includes Foundry tests to verify the airdrop logic.

## How It Works

1. **Prepare the Airdrop List:**  
   Create a list of addresses and token amounts eligible for the airdrop.

2. **Generate Merkle Tree & Proofs:**  
   Use the provided scripts to generate the Merkle root and proofs for each claimer.

3. **Deploy the Airdrop Contract:**  
   Deploy the `MerkleAirdrop` contract with the Merkle root and the token address.

4. **Claim Process:**  
   Eligible users call the `claim` function with their address, amount, and Merkle proof to receive their tokens.

## Usage

### 1. Generate Input File

Prepare a JSON file with the eligible addresses and amounts.

### 2. Generate Merkle Tree & Proofs

Run the provided scripts (see `script/MakeMerkle.s.sol`) to generate the Merkle root and proofs. The output will be saved in `/script/target/output.json`.

### 3. Deploy Contracts

Deploy your ERC20 token and the `MerkleAirdrop` contract, passing the Merkle root and token address to the constructor.

### 4. Claim Tokens

Eligible users can claim their tokens by calling the `claim` function with their proof.

## Example
