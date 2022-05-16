/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-solhint");
require('@nomiclabs/hardhat-ethers');
require('solidity-coverage');
require('dotenv').config()

module.exports = {
  solidity: "0.8.4",
  gas: 2100000,
  gasPrice: 8000000000,
};
