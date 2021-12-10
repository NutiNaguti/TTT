// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
require('dotenv').config()

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const TTT = await hre.ethers.getContractFactory("TTT");
  const TTT_ICO = await hre.ethers.getContractFactory("TTT_ICO");

  const ttt = await TTT.deploy(process.env.INITIAL_SUPPLY);
  const ttt_ico = await TTT_ICO.deploy(Math.floor(Date.now() / 1000), process.env.WALLET_ADDRESS, ttt.address);
  await ttt.setIcoConstract(ttt_ico.address);
  
  console.log("TTT deployed to:", ttt.address);
  console.log("TTT_ICO deployed to:", ttt_ico.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
