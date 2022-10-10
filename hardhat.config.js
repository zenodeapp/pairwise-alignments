require("@nomicfoundation/hardhat-toolbox");
const { task } = require("hardhat/config");
const web3 = require("web3");
const { getContract } = require("./helpers/web3");
const { contracts } = require("./proteins.config");

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
  .addParam("a")
  .addParam("b")
  .addParam("type")
  .addOptionalParam("gap", "", "-1")
  .addOptionalParam("limit", "", "0")
  .addOptionalParam("matrix", "", "default")
  .setAction(async (taskArgs, hre) => {
    const { a, b, type, gap, matrix, limit } = taskArgs;
    const contract = await getContract(
      hre,
      contracts.needlemanWunsch.name,
      contracts.needlemanWunsch.address
    );

    const result = await contract._needlemanWunsch(a, b, {
      gapPenalty: parseInt(gap),
      schemeType: type,
      substitutionMatrix: matrix,
      limit: parseInt(limit),
    });

    console.log(result);
    console.log({
      gap: parseInt(gap),
      type: type,
      matrix: matrix,
    });
  });

task("getMatrix")
  .addParam("id")
  .setAction(async (taskArgs, hre) => {
    const { id } = taskArgs;
    const contract = await getContract(
      hre,
      contracts.substitutionMatrices.name,
      contracts.substitutionMatrices.address
    );

    const result = await contract.getMatrix(id);

    console.log(result);
  });

task("getMatrices").setAction(async (_, hre) => {
  const contract = await getContract(
    hre,
    contracts.substitutionMatrices.name,
    contracts.substitutionMatrices.address
  );

  const result = await contract.getMatrices();

  console.log(result);
});

task("getAlphabet")
  .addParam("id")
  .setAction(async (taskArgs, hre) => {
    const { id } = taskArgs;
    const contract = await getContract(
      hre,
      contracts.substitutionMatrices.name,
      contracts.substitutionMatrices.address
    );

    const result = await contract.getAlphabet(id);

    console.log(result);
  });

task("getAlphabets").setAction(async (_, hre) => {
  const contract = await getContract(
    hre,
    contracts.substitutionMatrices.name,
    contracts.substitutionMatrices.address
  );

  const result = await contract.getAlphabets();

  console.log(result);
});

task("getScore")
  .addParam("matrix")
  .addParam("a")
  .addParam("b")
  .setAction(async (taskArgs, hre) => {
    const { matrix, a, b } = taskArgs;
    const contract = await getContract(
      hre,
      contracts.substitutionMatrices.name,
      contracts.substitutionMatrices.address
    );

    const result = await contract.getScore(
      matrix,
      web3.utils.toHex(a),
      web3.utils.toHex(b)
    );

    console.log(result);
  });
