pragma solidity >= 0.8.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TTT_ICO.sol";

import "hardhat/console.sol";

contract TTT is ERC20, Ownable {
    TTT_ICO public ico;
    address public icoAddress = address(0);

    
    uint public icoStartTimestamp;
    uint public icoEndTimeStamp; 

    mapping (address => bool) public whitelist;

    modifier whileIcoRunning() {
        if (block.timestamp > icoStartTimestamp && block.timestamp < icoEndTimeStamp) { 
            require(whitelist[msg.sender] == true,
                "While ICO running only werified users can transfer");
        }
        console.log();
        _;
    }

    event AddedToWhitelist(bool, address);

    constructor(uint initialSupply) ERC20("Test Task Token", "TTT") {
        _mint(msg.sender, initialSupply);
    }

    function setIcoConstract(address payable _icoAddress) public onlyOwner returns(bool) {
        require(icoAddress == address(0));
        icoAddress = _icoAddress;
        ico = TTT_ICO(_icoAddress);

        icoStartTimestamp = ico.getIcoStartTime();
        icoEndTimeStamp = ico.getIcoEndTime();

        return true;
    }

    function addToWhitelist(address icoParticipant) public onlyOwner {
        whitelist[icoParticipant] = true;
        emit AddedToWhitelist(true, icoParticipant);
    }

    function transfer(address recipient, uint256 amount) public override whileIcoRunning returns(bool) {
        return super.transfer(recipient, amount);
    }

    function inWhitelist(address user) public view returns(bool){
        return whitelist[user];
    }

}