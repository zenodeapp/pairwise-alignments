require("@nomicfoundation/hardhat-toolbox");
const { task } = require("hardhat/config");
const { getContract } = require("./submodules/zenode-contracts/helpers/web3");
const { contracts } = require("./zenode.config");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "localhost",
  networks: {
    hardhat: { gas: 2000000000, blockGasLimit: 2000000000 },
    localhost: { url: "http://127.0.0.1:8545", timeout: 100000000 },
    genesisd: {
      url: "https://rpcb.genesisL1.org",
      gas: 2000000000,
      chainId: 29,
      accounts: [],
      timeout: 100000000,
    },
  },
  mocha: {
    timeout: 100000000,
  },
};

task("needlemanWunsch")
  .addParam("matrix")
  .addParam("a")
  .addParam("b")
  .addOptionalParam("gap", "", "-1")
  .addOptionalParam("limit", "", "0")
  .setAction(async (taskArgs, hre) => {
    const { a, b, gap, matrix, limit } = taskArgs;
    const contract = await getContract(
      hre,
      contracts.needlemanWunsch.name,
      contracts.needlemanWunsch.address
    );

    const result = await contract._needlemanWunsch(a, b, {
      gap: parseInt(gap),
      limit: parseInt(limit),
      matrix,
    });

    console.log(result);
    console.log({
      gap: parseInt(gap),
      matrix: matrix,
    });
  });

task("smithWaterman")
  .addParam("matrix")
  .addParam("a")
  .addParam("b")
  .addOptionalParam("gap", "", "-1")
  .addOptionalParam("limit", "", "0")
  .setAction(async (taskArgs, hre) => {
    const { a, b, gap, matrix, limit } = taskArgs;
    const contract = await getContract(
      hre,
      contracts.smithWaterman.name,
      contracts.smithWaterman.address
    );

    const result = await contract._smithWaterman(a, b, {
      gap: parseInt(gap),
      limit: parseInt(limit),
      matrix,
    });

    console.log(result);
    console.log({
      gap: parseInt(gap),
      matrix: matrix,
    });
  });

task("linkNWToMatricesAddress")
  .addOptionalParam(
    "address",
    "",
    contracts.needlemanWunsch.parameters._matricesAddress
  )
  .setAction(async (taskArgs, hre) => {
    const { address } = taskArgs;
    const contract = await getContract(
      hre,
      contracts.needlemanWunsch.name,
      contracts.needlemanWunsch.address
    );

    const result = await contract._linkToMatricesAddress(address);

    if (result) {
      console.log(`Successfully linked Needleman-Wunsch to ${address}!`);
    }
  });

task("linkSWToMatricesAddress")
  .addOptionalParam(
    "address",
    "",
    contracts.smithWaterman.parameters._matricesAddress
  )
  .setAction(async (taskArgs, hre) => {
    const { address } = taskArgs;
    const contract = await getContract(
      hre,
      contracts.smithWaterman.name,
      contracts.smithWaterman.address
    );

    const result = await contract._linkToMatricesAddress(address);

    if (result) {
      console.log(`Successfully linked Smith-Waterman to ${address}!`);
    }
  });
