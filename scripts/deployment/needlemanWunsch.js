const { getAlignmentFactory } = require("../../helpers/web3");
const hre = require("hardhat");

async function main() {
  const NeedlemanWunschFactory = await getAlignmentFactory(hre);
  const needlemanWunsch = await NeedlemanWunschFactory.deploy();

  await needlemanWunsch.deployed();

  console.log();
  console.log(`NeedlemanWunsch contract has been deployed!`);
  console.log(`Address: ${needlemanWunsch.address}`);
  console.log();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
