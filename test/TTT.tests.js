const { BigNumber } = require("@ethersproject/bignumber");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TTT contract main tests", function() {
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

        await ttt.setIcoConstract(ttt_ico.address);
    });

    it("Only owner can add user to whitelist negative", async function() {
        await catchRevert(ttt_ico.connect(address1).addToWhitelist(address1.address));    
    });

    it("Only owner can add user to whitelist positive", async function() {
        await ttt_ico.addToWhitelist(address1.address);

        actual = await ttt_ico.whitelist(address1.address);
        expect(actual).to.equal(true);
    });

    it("Only veryfied user can buy TTT negative", async function() {
        await catchRevert(address1.sendTransaction({
            to: ttt_ico.address,
            value: ethers.utils.parseEther("1.0")
        }));
    });

    it("Only veryfied user can buy TTT positive", async function() {
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

    it("Only verified users can use transfer while ICO in progress negative", async function() {
        await catchRevert(ttt.connect(address1).transferWhileIco(address2.address, 1));
    });

    it("Only verified users can use transfer while ICO in progress positive", async function() {
        await ttt_ico.addToWhitelist(address1.address);
        
        const amount = BigNumber.from(ethers.utils.parseEther("1.5"));
        await address1.sendTransaction({
            to: ttt_ico.address,
            value: amount
        });
        const tttBalance = await ttt.balanceOf(address1.address);

        const balanceBeforeTransfer = await ttt.balanceOf(address2.address);
        await ttt.connect(address1).transferWhileIco(address2.address, tttBalance);
        const balanceAfterTransfer = await ttt.balanceOf(address2.address);

        expect(balanceAfterTransfer).to.equal(balanceBeforeTransfer + amount * 42);
    });

    it("Only verified users can use transferFrom while ICO in progress negative", async function() {
        await catchRevert(ttt.connect(address1).transferFromWhileIco(owner.address, address2.address, 1));
    });

    // it("Only verified users can use transferFrom while ICO in progress positive", async function() {
    //     await ttt_ico.addToWhitelist(address1.address);
        
    //     const amount = BigNumber.from(ethers.utils.parseEther("1.5"));
    //     await address2.sendTransaction({
    //         to: ttt_ico.address,
    //         value: amount
    //     });
    //     const tttBalance = await ttt.balanceOf(address1.address);

    // });
});

describe("Additional tests for different time", function() {
    let date = new Date();
    it("This case test rates in second phase of ICO", async function() {
        const TTT = await ethers.getContractFactory("TTT");
        const TTT_ICO = await ethers.getContractFactory("TTT_ICO");
        const [owner, address1, address2, ...addrs] = await ethers.getSigners();
    
        const ttt = await TTT.deploy(BigNumber.from(ethers.utils.parseEther("1000000000")));
        const ttt_ico = await TTT_ICO.deploy(Math.floor(date.setDate(date.getDate() - 4) / 1000), owner.address, ttt.address);

        await ttt.setIcoConstract(ttt_ico.address);


        await ttt_ico.addToWhitelist(address1.address);

        const amount = BigNumber.from(ethers.utils.parseEther("1.5"));
        const balanceBeforeTransfer = await ttt.balanceOf(address1.address);
        
        await address1.sendTransaction({
            to: ttt_ico.address,
            value: amount
        });

        const balanceAfterTransfer = await ttt.balanceOf(address1.address);
        expect(balanceAfterTransfer).to.equal(balanceBeforeTransfer + amount * 21);
    });

    it("This case test rates in third phase of ICO", async function() {
        const TTT = await ethers.getContractFactory("TTT");
        const TTT_ICO = await ethers.getContractFactory("TTT_ICO");
        const [owner, address1, address2, ...addrs] = await ethers.getSigners();
    
        const ttt = await TTT.deploy(BigNumber.from(ethers.utils.parseEther("1000000000")));
        const ttt_ico = await TTT_ICO.deploy(Math.floor(date.setDate(date.getDate() - 34) / 1000), owner.address, ttt.address);

        await ttt.setIcoConstract(ttt_ico.address);


        await ttt_ico.addToWhitelist(address1.address);

        const amount = BigNumber.from(ethers.utils.parseEther("1.5"));
        const balanceBeforeTransfer = await ttt.balanceOf(address1.address);
        
        await address1.sendTransaction({
            to: ttt_ico.address,
            value: amount
        });

        const balanceAfterTransfer = await ttt.balanceOf(address1.address);
        expect(balanceAfterTransfer).to.equal(balanceBeforeTransfer + amount * 8);
    });

    it("This case test buying TTT after ICO ending", async function() {
        const TTT = await ethers.getContractFactory("TTT");
        const TTT_ICO = await ethers.getContractFactory("TTT_ICO");
        const [owner, address1, address2, ...addrs] = await ethers.getSigners();
    
        const ttt = await TTT.deploy(BigNumber.from(ethers.utils.parseEther("1000000000")));
        const ttt_ico = await TTT_ICO.deploy(Math.floor(date.setDate(date.getDate() - 48) / 1000), owner.address, ttt.address);

        await ttt.setIcoConstract(ttt_ico.address);


        await ttt_ico.addToWhitelist(address1.address);

        const amount = BigNumber.from(ethers.utils.parseEther("1.5"));
        const balanceBeforeTransfer = await ttt.balanceOf(address1.address);
        
        await address1.sendTransaction({
            to: ttt_ico.address,
            value: amount
        });

        const balanceAfterTransfer = await ttt.balanceOf(address1.address);
        expect(balanceAfterTransfer).to.equal(balanceBeforeTransfer);
    });
});