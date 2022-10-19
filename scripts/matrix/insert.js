const fs = require("fs/promises");
const { getContract } = require("../../submodules/zenode-helpers/helpers/web3");
const { matrices, contracts, matrixToInsert } = require("../../zenode.config");
const web3 = require("web3");

async function main() {
  const contract = await getContract(
    hre,
    contracts.substitutionMatrices.name,
    contracts.substitutionMatrices.address
  );

  if (Array.isArray(matrixToInsert)) {
    for (let i = 0; i < matrixToInsert.length; i++) {
      const res = await insertMatrix(contract, matrixToInsert[i]);
      await res.wait();
    }
  } else {
    insertMatrix(contract, matrixToInsert);
  }
}

const insertMatrix = async (contract, matrixId) => {
  const file = await fs.readFile(matrices[matrixId].file, {
    encoding: "utf8",
  });

  let matrix = file.split(/\r?\n/).map((line, i) => {
    const splittedLine = line.trim().split(/\s+/);

    if (i > 0) splittedLine.shift();
    return splittedLine;
  });

  const alphabet = matrix.shift().map((char) => web3.utils.toHex(char));

  // Test if the matrix alphabet order is correct with what is known to the contract
  const testAlphabet = await contract.testAlphabet(
    matrices[matrixId].alphabet,
    alphabet
  );

  // await testAlphabet.wait();

  if (!testAlphabet) {
    return console.log(
      "Inserting matrix failed because the order of the alphabet is not the same as what's known."
    );
  }

  // Insert matrix if the alphabet test passed.
  const insertMatrix = await contract.insertMatrix(
    matrixId,
    matrices[matrixId].alphabet,
    matrix
  );

  console.log(`Successfully inserted the ${matrixId}-matrix!`);
  console.log();
  console.log("Array (in Solidity):");
  console.log(matrix);
  return insertMatrix;
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
