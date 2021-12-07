pragma solidity >= 0.8.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TTT_ICO.sol";

contract TTT is ERC20, Ownable {
    TTT_ICO public ico;

    address owner;
    
    uint public icoStartTimestamp;
    uint public icoEndTimeStamp; 

    mapping (address => bool) public whitelist;

    modifier whileIcoRunning() {
        if (block.timestamp > icoStartTimestamp && block.timestamp < icoEndTimeStamp) { 
            require(whitelist[msg.sender] == true,
                "While ico running only werified users can transfer");
        }
        _;
    }

    event AddedToWhitelist(bool, address);

    constructor(uint initialSupply) ERC20("Test Task Token", "TTT") {
        owner = msg.sender;
        _mint(msg.sender, initialSupply);
    }

    function setIcoConstract(address payable icoAddress) public returns(bool) {
        ico = TTT_ICO(icoAddress);

        icoStartTimestamp = ico.getIcoStartTime();
        icoEndTimeStamp = ico.getIcoEndTime();
    }

    function addToWhitelist(address icoParticipant) public onlyOwner {
        whitelist[icoParticipant] = true;
        emit AddedToWhitelist(true, icoParticipant);
    }

    function transfer(address recipient, uint256 amount) public override whileIcoRunning returns(bool) {
        return super.transfer(recipient, amount);
    }
}