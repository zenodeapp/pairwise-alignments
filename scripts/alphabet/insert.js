const fs = require("fs/promises");
const { getContract } = require("../../helpers/web3");
const {
  contracts,
  alphabets,
  alphabetToInsert,
} = require("../../zenode.config");
const web3 = require("web3");

async function main() {
  const contract = await getContract(
    hre,
    contracts.substitutionMatrices.name,
    contracts.substitutionMatrices.address
  );

  if (Array.isArray(alphabetToInsert)) {
    for (let i = 0; i < alphabetToInsert.length; i++) {
      const res = await insertAlphabet(contract, alphabetToInsert[i]);
      await res.wait();
    }
  } else {
    insertAlphabet(contract, alphabetToInsert);
  }
}

const insertAlphabet = async (contract, alphabetId) => {
  const file = await fs.readFile(alphabets[alphabetId], {
    encoding: "utf8",
  });

  let alphabet = file.split(/\r?\n/).map((line) => line.trim().split(/\s+/));
  alphabet = [].concat(...alphabet);
  const bytesAlphabet = alphabet.map((char) => web3.utils.toHex(char));

  const insertAlphabet = await contract.insertAlphabet(
    alphabetId,
    bytesAlphabet
  );

  console.log(`Successfully inserted the ${alphabetId}-alphabet!`);
  console.log();
  console.log("Human-readable format:");
  console.log(alphabet);
  console.log();
  console.log("Bytes-array (in Solidity):");
  console.log(bytesAlphabet);

  return insertAlphabet;
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
