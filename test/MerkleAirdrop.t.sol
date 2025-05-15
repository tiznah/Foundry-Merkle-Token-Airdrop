// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagleToken} from "../src/BagleToken.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol"; // checks if contract is deployed on zksync since contracts historically could not be deployed with scripts

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    // Deploy contract and set as environment variable
    MerkleAirdrop public airdrop;
    BagleToken public token;
    address public user;
    uint256 public userPrivKey;
    address public gasPayer;
    address public randomUser;
    uint256 public randomUserPrivKey;
    uint256 public AMOUNT_TO_CLAIM = 25 ether;
    uint256 public AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 4;
    bytes32 public proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];

    bytes32 public merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    function setUp() public {
        if (isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagleToken();
            airdrop = new MerkleAirdrop(address(token), merkleRoot);
            token.mint(token.owner(), AMOUNT_TO_MINT);
            token.transfer(address(airdrop), AMOUNT_TO_MINT);
        }
        (user, userPrivKey) = makeAddrAndKey("user");
        (randomUser, randomUserPrivKey) = makeAddrAndKey("randomUser");
        gasPayer = makeAddr("gasPayer");
    }

    function testUserCanClaimForSelf() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessage(user, AMOUNT_TO_CLAIM); // from the MerkleAirdrop contract
        vm.startPrank(user); // prank the user to sign a message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest); // takes private key and returns v, r, s
        vm.stopPrank();
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
    function testGasPayerCanClaimOnBehalfOfUser() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessage(user, AMOUNT_TO_CLAIM); // from the MerkleAirdrop contract
        vm.startPrank(user); // prank the user to sign a message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest); // takes private key and returns v, r, s
        vm.stopPrank();

        vm.startPrank(gasPayer); // now the gaspayer is claiming on behalf of the user
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.stopPrank();
        uint256 endingBalance = token.balanceOf(user);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
    function testUserCannotClaimAfterGasPayerClaimed() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessage(user, AMOUNT_TO_CLAIM); // from the MerkleAirdrop contract
        vm.startPrank(user); // prank the user to sign a message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest); // takes private key and returns v, r, s
        vm.stopPrank();

        vm.startPrank(gasPayer); // now the gaspayer is claiming on behalf of the user
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.stopPrank();
        vm.startPrank(user);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.stopPrank();
        uint256 endingBalance = token.balanceOf(user);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }

    function testRandomUserCannotClaim() public {
        uint256 startingBalance = token.balanceOf(randomUser);
        bytes32 digest = airdrop.getMessage(randomUser, AMOUNT_TO_CLAIM); // from the MerkleAirdrop contract
        vm.startPrank(randomUser); // prank the user to sign a message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(randomUserPrivKey, digest); // takes private key and returns v, r, s
        vm.stopPrank();
        vm.startPrank(user);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidProof.selector);
        airdrop.claim(randomUser, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.stopPrank();
        uint256 endingBalance = token.balanceOf(randomUser);
        assertEq(endingBalance - startingBalance, 0);
    }
}
