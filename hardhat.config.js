require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('solidity-coverage')
require('dotenv').config()

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    rinkeby: {
      url: process.env.REINKEBY_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
