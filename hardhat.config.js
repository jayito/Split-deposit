require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
let secret = require('./secret')

const optimizerEnabled = !process.env.OPTIMIZER_DISABLED;
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.7.6",
  networks: {
    bsc: {
      url: [secret.bsc_url],
      accounts:[secret.key]
    },
    bsctestnet: {
      url: [secret.bsctestnet_url],
      accounts: [secret.key]
    },
    eth: {
      url: [secret.eth_url],
      accounts: [secret.key]
    }
  },
  etherscan: {
    apiKey: [secret.apikey]
  },
  solidity: {
    compilers: [
      
      {
        version: '0.8.1',
        settings: {
          optimizer: {
            enabled: optimizerEnabled,
            runs: 2000,
          },
          evmVersion: 'berlin',
        },
      },
      {
        version: '0.8.0',
        settings: {
          optimizer: {
            enabled: optimizerEnabled,
            runs: 2000,
          },
          evmVersion: 'berlin',
        },
      }
    ],
  },
};
