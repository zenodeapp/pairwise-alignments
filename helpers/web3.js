//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const { contracts } = require("../proteins.config");

const getAlignmentContract = async (hre) => {
  const contract = await hre.ethers.getContractAt(
    contracts.alignmentContract.name,
    contracts.alignmentContract.address
  );

  return contract;
};

const getAlignmentFactory = async (hre, config) => {
  const Factory = await hre.ethers.getContractFactory(
    contracts.alignmentContract.name,
    config
  );

  return Factory;
};

module.exports = {
  getAlignmentContract,
  getAlignmentFactory,
};
