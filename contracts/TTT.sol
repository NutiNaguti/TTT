// SPDX-License-Identifier: MIT
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

    modifier whenIcoFinished {
        require(msg.sender != icoAddress);
        require(block.timestamp > icoEndTimeStamp, "Avalibale only after ICO");
        _;
    }

    modifier whenIcoInProgress {
        require(block.timestamp > icoStartTimestamp && block.timestamp <= icoEndTimeStamp, "Avalibale only during ICO");
        require(ico.whitelist(msg.sender) == true, "Only verified users can use transaction while ICO");
        _;
    }

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

    function transferFromIco(address recipient, uint amount) public returns(bool) {
        require(msg.sender == icoAddress);
        return super.transfer(recipient, amount);
    }

    function transferWhileIco(address recipient, uint amount) public whenIcoInProgress returns(bool) {
        return super.transfer(recipient, amount);
    }
    
    function transferFromWhileIco(address from, address to, uint amount) public whenIcoInProgress returns(bool) {
        return super.transferFrom(from, to, amount);
    }

    function transfer(address recipient, uint amount) public whenIcoFinished override returns(bool) {
        return super.transfer(recipient, amount);
    }
        
    function transferFrom(address from, address to, uint amount) public whenIcoFinished override returns(bool) {
        return super.transferFrom(from, to, amount);
    }

    function approve(address spender, uint amount) public whenIcoFinished override returns(bool) {
        return super.approve(spender, amount);
    }
}