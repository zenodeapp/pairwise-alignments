const { getContract } = require("../../submodules/zenode-helpers/helpers/web3");
const { contracts, alphabetToDelete } = require("../../zenode.config");

async function main() {
  const contract = await getContract(
    hre,
    contracts.substitutionMatrices.name,
    contracts.substitutionMatrices.address
  );

  if (Array.isArray(alphabetToDelete)) {
    for (let i = 0; i < alphabetToDelete.length; i++) {
      const res = await deleteAlphabet(contract, alphabetToDelete[i]);
      await res.wait();
    }
  } else {
    deleteAlphabet(contract, alphabetToDelete);
  }
}

const deleteAlphabet = async (contract, alphabetId) => {
  const deleteAlphabet = await contract.deleteAlphabet(alphabetId);

  console.log(`Successfully deleted the ${alphabetId}-alphabet!`);
  return deleteAlphabet;
};

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
