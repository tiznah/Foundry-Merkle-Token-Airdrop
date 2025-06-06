// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagleToken} from "../src/BagleToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public s_amountToTransfer = 4 * 25 ether;

    function deployMerkleAirdrop() public returns (MerkleAirdrop, BagleToken) {
        vm.startBroadcast();
        BagleToken token = new BagleToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(address(token), s_merkleRoot);
        token.mint(token.owner(), s_amountToTransfer);
        IERC20(token).transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() external returns (MerkleAirdrop, BagleToken) {
        return deployMerkleAirdrop();
    }
}
