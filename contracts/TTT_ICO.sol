pragma solidity >= 0.8.0 < 0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./TTT.sol";

contract TTT_ICO {
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

    event TokenPurchased(address, uint, uint);

    constructor(
        uint phase1StartTime,
        address payable walletAddress,
        address tokenRewardAddress
    ) {
        require(tokenRewardAddress != address(0));
        require(walletAddress != address(0));
        wallet = walletAddress;

        phase1Opening = phase1StartTime;
        phase1Closing = phase1Opening.add(3 * 24 * 60 * 60);

        phase2Opening = phase1Closing;
        phase2Closing = phase2Opening.add(30 * 24 * 60 * 60);

        phase3Opening = phase2Closing;
        phase3Closing = phase3Opening.add(14 * 24 * 60 * 60);
    }

    receive() external payable {
        Phase currentPhase = getCuurentPhase();
        require(currentPhase != Phase.NotRunning ||
            currentPhase != Phase.Ended, "ICO is not running");

        uint tttAmount = 0;
        uint weiAmount = msg.value;

        if (currentPhase == Phase.Phase1) {
            tttAmount = weiAmount.mul(Phase1Rate);
        } else if (currentPhase == Phase.Phase2) {
            tttAmount = weiAmount.mul(Phase2Rate);
        } else if (currentPhase == Phase.Phase3) {
            tttAmount = weiAmount.mul(Phase3Rate);
        }
        
        tokenReward.transfer(msg.sender, tttAmount);
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

    function getIcoStartTime() public view returns(uint) {
        return phase1Opening;
    }

    function getIcoEndTime() public view returns(uint) {
        return phase3Closing;
    }
}