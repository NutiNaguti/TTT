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

    uint initialSupply;

    constructor(uint _initialSupply) ERC20("Test Task Token", "TTT") {
        initialSupply = _initialSupply;
    }

    function setIcoConstract(address payable _icoAddress) public onlyOwner returns(bool) {
        require(icoAddress == address(0));
        icoAddress = _icoAddress;
        ico = TTT_ICO(_icoAddress);
        _mint(icoAddress, initialSupply);

        icoStartTimestamp = ico.getIcoStartTime();
        icoEndTimeStamp = ico.getIcoEndTime();

        return true;
    }

    function transferFromICO(address recipient, uint256 amount) public returns(bool) {
        require(msg.sender == icoAddress);
        return super.transfer(recipient, amount);
    }
}