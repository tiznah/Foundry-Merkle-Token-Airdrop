// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    // some list of addresses and allow them to claim tokens
    address[] public claimers;
    bytes32 public i_merkleRoot;
    IERC20 private immutable i_bagleToken;
    mapping(address claimer => bool isClaimed) private s_claimed;

    // EIP712
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    using SafeERC20 for IERC20; // to avoid reverts from ERC20

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    event Claimed(address indexed account, uint256 amount);

    constructor(address _bagleToken, bytes32 _merkleRoot) EIP712("MerkleAirdrop", "1") {
        i_bagleToken = IERC20(_bagleToken);
        i_merkleRoot = _merkleRoot;
    }

    function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        require(!s_claimed[_account], MerkleAirdrop__AlreadyClaimed());
        // checking if the signature it valid if not revert
        // message is the digest
        if (!_isValidSignature(_account, getMessage(_account, _amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount)))); // avoid second preeimage attack by hashing twice
        require(MerkleProof.verify(_merkleProof, i_merkleRoot, leaf), MerkleAirdrop__InvalidProof());
        emit Claimed(_account, _amount);
        s_claimed[_account] = true;
        i_bagleToken.safeTransfer(_account, _amount);
    }
    // checks if the signature is valid

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        public
        pure
        returns (bool)
    {
        // using Openzeppelin ecrecover
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
    // get the digest

    function getMessage(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirDropTokenAddress() public view returns (address) {
        return address(i_bagleToken);
    }
}
