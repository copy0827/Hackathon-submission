require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.30",
    settings: { optimizer: { enabled: true, runs: 200 } },
  },
  networks: {
    zetachain_athens_testnet: {
      url: "https://zetachain-athens-evm.blockpi.network/v1/rpc/public",  // ⭐ BlockPI 엔드포인트
      accounts: [process.env.PRIVATE_KEY],
      chainId: 7001,  // Athens Testnet Chain ID
    },
  },
};
