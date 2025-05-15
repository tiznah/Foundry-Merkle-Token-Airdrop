# Merkle Tree Token Airdrop

This repository implements a secure and gas-efficient token airdrop using a Merkle tree for authentication of claimers. The Merkle tree enables on-chain verification that a given address and amount are eligible for the airdrop, without storing or revealing the entire list of claimers.

> **⚠️ Work in Progress:**  
> This project is under active development. The code and documentation are subject to change. Use at your own risk.

---

## Table of Contents

- [Overview](#overview)
- [How It Works](#how-it-works)
- [Directory Structure](#directory-structure)
- [Usage](#usage)
  - [1. Prepare Input File](#1-prepare-input-file)
  - [2. Generate Merkle Tree & Proofs](#2-generate-merkle-tree--proofs)
  - [3. Deploy Contracts](#3-deploy-contracts)
  - [4. Claim Tokens](#4-claim-tokens)
  - [5. Local zkSync Demo](#5-local-zksync-demo)
- [Testing](#testing)
- [Example](#example)
- [References](#references)

---

## Overview

- **Airdrop Contract:**  
  The smart contract ([`src/MerkleAirdrop.sol`](src/MerkleAirdrop.sol)) allows eligible users to claim tokens by providing a valid Merkle proof and EIP-712 signature.
- **Merkle Tree Generation:**  
  Scripts in [`script/`](script/) generate the Merkle root and proofs from a list of eligible addresses and amounts.
- **Testing:**  
  Includes Foundry tests ([`test/MerkleAirdrop.t.sol`](test/MerkleAirdrop.t.sol)) to verify the airdrop logic and edge cases.

---

## How It Works

1. **Prepare the Airdrop List:**  
   Create a JSON file with addresses and token amounts eligible for the airdrop.

2. **Generate Merkle Tree & Proofs:**  
   Use the provided scripts to generate the Merkle root and proofs for each claimer.

3. **Deploy the Airdrop Contract:**  
   Deploy the `MerkleAirdrop` contract with the Merkle root and the token address.

4. **Claim Process:**  
   Eligible users call the `claim` function with their address, amount, Merkle proof, and EIP-712 signature to receive their tokens.

---
## Gas Sponsoring: Claiming on Behalf of a User

### What is Gas Sponsoring?

Gas sponsoring allows a third party (the "gas payer") to submit a claim transaction on behalf of an eligible user. This is useful when the user does not have ETH to pay for gas, or when a service wants to sponsor the claim process for its users.

### How Does It Work?

- **Signature-Based Authorization:**  
  The MerkleAirdrop contract requires an EIP-712 signature from the eligible user, authorizing the claim for a specific amount. This signature can be generated off-chain by the user and given to the gas payer.

- **Anyone Can Submit:**  
  Anyone (not just the user) can call the `claim` function, as long as they provide:
  - The user's address
  - The claim amount
  - The correct Merkle proof
  - The valid EIP-712 signature from the user

- **Security:**  
  The contract verifies that:
  - The Merkle proof is valid for the user and amount
  - The signature matches the user's address and amount
  - The claim has not already been made

### Example Flow

1. **User signs a claim message** (off-chain) for their address and amount.
2. **Gas payer collects the signature** and Merkle proof from the user.
3. **Gas payer submits the claim** by calling the contract's `claim` function, paying the gas.
4. **User receives tokens** directly to their address.

### Example

Suppose Alice is eligible for the airdrop but has no ETH. She signs the claim message and sends it to Bob (the gas payer). Bob submits the claim on-chain, paying the gas, and Alice receives her tokens.

This pattern is supported out-of-the-box by the contract and is tested in [`test/MerkleAirdrop.t.sol`](test/MerkleAirdrop.t.sol) (see `testGasPayerCanClaimOnBehalfOfUser`).

> **Note:**  
> The signature is only valid for the specific address and amount, and can only be used once. This prevents replay attacks and double claims.


