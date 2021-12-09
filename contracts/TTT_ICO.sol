// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0 < 0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TTT.sol";

import "hardhat/console.sol";

contract TTT_ICO is Ownable {
    TTT public tokenReward;

    using SafeMath for uint256;

    enum Phase { 
        NotRunning,
        Phase1,
        Phase2,
        Phase3,
        Ended
    }

    uint public constant Phase1Rate = 42;
    uint public constant Phase2Rate = 21;
    uint public constant Phase3Rate = 8;

    uint public phase1Opening;
    uint public phase2Opening;
    uint public phase3Opening;

    uint public phase1Closing;
    uint public phase2Closing;
    uint public phase3Closing;

    address payable wallet;
    
    mapping (address => bool) public whitelist;

    modifier whenIcoInProgress() {
        Phase currentPhase = getCuurentPhase();
        if (currentPhase != Phase.NotRunning && 
            currentPhase != Phase.Ended) { 
            
            require(whitelist[msg.sender] == true, "While ICO running only werified users can transfer");
        }
        _;
    }

    event AddedToWhitelist(bool, address);
    event TokenPurchased(address, uint, uint);

    constructor(
        uint phase1StartTime,
        address payable walletAddress,
        address tokenRewardAddress
    ) {
        require(tokenRewardAddress != address(0));
        require(walletAddress != address(0));

        tokenReward = TTT(tokenRewardAddress);
        wallet = walletAddress;

        phase1Opening = phase1StartTime;
        phase1Closing = phase1Opening.add(3 * 24 * 60 * 60);

        phase2Opening = phase1Closing;
        phase2Closing = phase2Opening.add(30 * 24 * 60 * 60);

        phase3Opening = phase2Closing;
        phase3Closing = phase3Opening.add(14 * 24 * 60 * 60);
    }

    receive() external payable whenIcoInProgress {
        Phase currentPhase = getCuurentPhase();
        require(currentPhase != Phase.NotRunning || currentPhase != Phase.Ended, "ICO not in progress");
        require(whitelist[msg.sender] == true, "While ICO in progress only werified users can transfer");
        require(msg.value != 0, "Insufficient funds");

        uint tttAmount = 0;
        uint weiAmount = msg.value;

        if (currentPhase == Phase.Phase1) {
            tttAmount = weiAmount.mul(Phase1Rate);
        } else if (currentPhase == Phase.Phase2) {
            tttAmount = weiAmount.mul(Phase2Rate);
        } else if (currentPhase == Phase.Phase3) {
            tttAmount = weiAmount.mul(Phase3Rate);
        }
        
        tokenReward.transferFromIco(msg.sender, tttAmount);
        wallet.transfer(msg.value);

        emit TokenPurchased(msg.sender, weiAmount, tttAmount);
    }

    function getCuurentPhase() public view returns(Phase) {
        Phase currentPhase = Phase.NotRunning;

        if (block.timestamp >= phase1Opening && block.timestamp <= phase1Closing) {
            currentPhase = Phase.Phase1;
        } else if (block.timestamp >= phase2Opening && block.timestamp <= phase2Closing) {
            currentPhase = Phase.Phase2;
        } else if (block.timestamp >= phase3Opening && block.timestamp <= phase3Closing) {
            currentPhase = Phase.Phase3;
        } else if (block.timestamp > phase3Closing)
            currentPhase = Phase.Ended;

        return currentPhase;
    }

    function addToWhitelist(address icoParticipant) public onlyOwner {
        whitelist[icoParticipant] = true;
        emit AddedToWhitelist(true, icoParticipant);
    }

    function getIcoStartTime() public view returns(uint) {
        return phase1Opening;
    }

    function getIcoEndTime() public view returns(uint) {
        return phase3Closing;
    }
}