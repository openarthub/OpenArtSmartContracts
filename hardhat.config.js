/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require('@nomiclabs/hardhat-solhint');
require('@nomiclabs/hardhat-etherscan');
require('@nomiclabs/hardhat-ethers');
require('solidity-coverage');
require('dotenv').config({path: `./.env${process.env.ENV ? '.' + process.env.ENV : ''}`});
console.log(`./.env${process.env.ENV ? '.' + process.env.ENV : ''}`);

module.exports = {
  solidity: '0.8.4',

  etherscan: {
    apiKey: {
      polygonMumbai: process.env.API_KEY_SCAN,
    },
  },

  networks: {
    testnet: {
      url: process.env.URL_RPC,
      accounts: [process.env.DEPLOYER_WALLET_PRIVATE_KEY],
    },
    ganache: {
      url: process.env.URL_RPC,
      accounts: [process.env.DEPLOYER_WALLET_PRIVATE_KEY],
    },
    mumbai: {
      url: process.env.URL_RPC_MUMBAI,
      accounts: [process.env.DEPLOYER_WALLET_PRIVATE_KEY],
    },
    binance: {
      url: process.env.URL_RPC,
      accounts: [process.env.DEPLOYER_WALLET_PRIVATE_KEY],
    },

    polygon: {
      url: process.env.URL_RPC_POLYGON,
      accounts: [process.env.DEPLOYER_WALLET_PRIVATE_KEY],
    },
  },
};
