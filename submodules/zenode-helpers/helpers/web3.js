// Created by ZENODE (zenodeapp - https://github.com/zenodeapp/)

const getContract = async (hre, name, address) => {
  const contract = await hre.ethers.getContractAt(name, address);

  return contract;
};

const getFactory = async (hre, name, config) => {
  const Factory = await hre.ethers.getContractFactory(name, config);

  return Factory;
};

module.exports = {
  getContract,
  getFactory,
};
