/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-solhint");
require('@nomiclabs/hardhat-ethers');
require('solidity-coverage');
require('dotenv').config()

module.exports = {
  solidity: "0.8.4",
  gas: 1000000000000000,
  gasPrice: 8000000000,

  networks: {
    testnet: {
      url: process.env.URL_RPC,
      accounts: [process.env.WALLET_PRIVATE_KEY]
    }
  }
};
