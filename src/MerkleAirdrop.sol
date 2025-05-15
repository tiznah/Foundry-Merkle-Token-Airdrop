// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    // some list of addresses and allow them to claim tokens
    address[] public claimers;
    bytes32 public i_merkleRoot;
    IERC20 private immutable i_bagleToken;
    mapping(address claimer => bool isClaimed) private s_claimed;

    using SafeERC20 for IERC20; // to avoid reverts from ERC20

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    event Claimed(address indexed account, uint256 amount);

    constructor(address _bagleToken, bytes32 _merkleRoot) {
        i_bagleToken = IERC20(_bagleToken);
        i_merkleRoot = _merkleRoot;
    }

    function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof) external {
        require(!s_claimed[_account], MerkleAirdrop__AlreadyClaimed());
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount)))); // avoid second preeimage attack by hashing twice
        require(MerkleProof.verify(_merkleProof, i_merkleRoot, leaf), MerkleAirdrop__InvalidProof());
        emit Claimed(_account, _amount);
        s_claimed[_account] = true;
        i_bagleToken.safeTransfer(_account, _amount);
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirDropTokenAddress() public view returns (address) {
        return address(i_bagleToken);
    }
}
