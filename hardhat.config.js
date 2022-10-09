require("@nomicfoundation/hardhat-toolbox");
const { task } = require("hardhat/config");
const web3 = require("web3");
const { getAlignmentContract } = require("./helpers/web3");

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
  },
  mocha: {
    timeout: 100000000,
  },
};

task("needlemanWunsch", "Returns information about this indexer.")
  .addParam("a", "The seed size.")
  .addParam("b", "The seed address to add to the protein indexer.")
  .addParam("type", "The seed address to add to the protein indexer.")
  .addOptionalParam(
    "gap",
    "The seed address to add to the protein indexer.",
    "-1"
  )
  .addOptionalParam(
    "limit",
    "The seed address to add to the protein indexer.",
    "0"
  )
  // .addOptionalParam(
  //   "showmatrices",
  //   "The seed address to add to the protein indexer.",
  //   "false"
  // )
  .addOptionalParam(
    "matrix",
    "The seed address to add to the protein indexer.",
    "default"
  )
  .setAction(async (taskArgs, hre) => {
    const { a, b, type, gap, matrix, limit } = taskArgs;
    const contract = await getAlignmentContract(hre);

    const result = await contract.needlemanWunsch(a, b, {
      gapPenalty: parseInt(gap),
      schemeType: type,
      substitutionMatrix: matrix,
      // showMatrices: showmatrices === "true",
      limit: parseInt(limit),
    });
    // let str = "";
    // // console.log(result.matrices.tracebackMatrix[0].positions[0]);
    // for (let i = 0; i < result.matrices.tracebackMatrix.length; i++) {
    //   if (i % 8 === 0) str = str + "\n";
    //   str = str + "[";
    //   for (
    //     let j = 0;
    //     j < result.matrices.tracebackMatrix[i].positions.length;
    //     j++
    //   ) {
    //     str = str + result.matrices.tracebackMatrix[i].positions[j];
    //     // switch (result.matrices.tracebackMatrix[i].positions[j]) {
    //     //   case 0:
    //     //     str = `${str}, current`;
    //     //     break;
    //     //   case 1:
    //     //     str = `${str}, left`;
    //     //     break;
    //     //   case 2:
    //     //     str = `${str}, up`;
    //     //     break;
    //     //   case 3:
    //     //     str = `${str}, diag`;
    //     //     break;
    //     // }
    //   }
    //   str = str + "], ";
    // }

    // console.log(str);

    // str = "";
    // for (let i = 0; i < result.matrices.scoreMatrix.length; i++) {
    //   if (i % 8 === 0) str = str + "\n";
    //   str = str + result.matrices.scoreMatrix[i];
    //   // switch (result.matrices.tracebackMatrix[i].positions[j]) {
    //   //   case 0:
    //   //     str = `${str}, current`;
    //   //     break;
    //   //   case 1:
    //   //     str = `${str}, left`;
    //   //     break;
    //   //   case 2:
    //   //     str = `${str}, up`;
    //   //     break;
    //   //   case 3:
    //   //     str = `${str}, diag`;
    //   //     break;
    //   // }
    //   str = str + ", ";
    // }
    // console.log(str);
    console.log(result);
    console.log({
      gap: parseInt(gap),
      schemeType: type,
      substitutionMatrix: matrix,
    });
  });
