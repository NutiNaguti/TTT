const { expect, assert } = require("chai");
const { ethers } = require("hardhat");

describe("TTT contract", function() {
    let TTT;
    let ttt;

    let TTT_ICO;
    let ttt_ico;

    let owner;
    let address1;
    let address2;
    let addrs;

    let catchRevert = require("./helpers/exeptions").catchRevert;

    beforeEach(async function () {
        TTT = await ethers.getContractFactory("TTT");
        TTT_ICO = await ethers.getContractFactory("TTT_ICO");
        [owner, address1, address2, ...addrs] = await ethers.getSigners();
    
        ttt = await TTT.deploy(1000);      
        ttt_ico = await TTT_ICO.deploy(Math.floor(Date.now() / 1000), owner.address, ttt.address);
    });

    it("Adding addres to whitelist should add address to address array", async function() {
        await ttt.setIcoConstract(ttt_ico.address);
        await ttt.addToWhitelist(owner.address);

        actual = await ttt.inWhitelist(owner.address);
        expect(actual).to.equal(true);
    });

    it("Only owner can add user to whitelist", async function() {
        await ttt.setIcoConstract(ttt_ico.address);
        await catchRevert(ttt.connect(address1).addToWhitelist(address1.address));    
    });
});