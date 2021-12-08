const { BigNumber } = require("@ethersproject/bignumber");
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
    
        ttt = await TTT.deploy(BigNumber.from(ethers.utils.parseEther("1000000000")));
        ttt_ico = await TTT_ICO.deploy(Math.floor(Date.now() / 1000), owner.address, ttt.address);
    });

    it("Adding addres to whitelist should add address to address array", async function() {
        await ttt.setIcoConstract(ttt_ico.address);
        await ttt_ico.addToWhitelist(owner.address);

        actual = await ttt_ico.inWhitelist(owner.address);
        expect(actual).to.equal(true);
    });

    it("Only owner can add user to whitelist", async function() {
        await ttt.setIcoConstract(ttt_ico.address);
        await catchRevert(ttt_ico.connect(address1).addToWhitelist(address1.address));    
    });

    it("Only weryfied user can buy TTT negative", async function() {
        await ttt.setIcoConstract(ttt_ico.address);
        await catchRevert(address1.sendTransaction({
            to: ttt_ico.address,
            value: ethers.utils.parseEther("1.0")
        }));
    });

    it("Only weryfied user can buy TTT positive", async function() {
        await ttt.setIcoConstract(ttt_ico.address);
        await ttt_ico.addToWhitelist(address1.address);

        const amount = BigNumber.from(ethers.utils.parseEther("1.5"));
        const balanceBeforeTransfer = await ttt.balanceOf(address1.address);
        
        await address1.sendTransaction({
            to: ttt_ico.address,
            value: amount
        });

        const balanceAfterTransfer = await ttt.balanceOf(address1.address);
        expect(balanceAfterTransfer).to.equal(balanceBeforeTransfer + amount * 42);
    });
});