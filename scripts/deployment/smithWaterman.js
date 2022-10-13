const { getFactory } = require("../../helpers/web3");
const { contracts } = require("../../zenode.config");
const hre = require("hardhat");

async function main() {
  const contractName = contracts.smithWaterman.name;

  const Factory = await getFactory(hre, contractName);
  const contract = await Factory.deploy(
    contracts.smithWaterman.parameters._matricesAddress
  );

  await contract.deployed();

  console.log();
  console.log(`${contractName} contract has been deployed!`);
  console.log(`Address: ${contract.address}`);
  console.log();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
