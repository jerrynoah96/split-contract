// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // first deploy $stake token
  const stakeToken = await hre.ethers.getContractFactory("Stake");
  const deployedStakeToken = await stakeToken.deploy();
  await deployedStakeToken.deployed();
  const $stake_address = deployedStakeToken.address;

  //deploy split contract passing the address of stakeToken in constructor

  const split = await hre.ethers.getContractFactory("Split");
  const deployedSplitContract = await split.deploy($stake_address);
  await deployedSplitContract.deployed();




 

  console.log("$stakeToken deployed at:", $stake_address);
  console.log("split contract deployed at:", deployedSplitContract.address );
}
//stakeToken deployed at: 0xFb353774Ace94C3Eaa9fD04E7D2C4c48537A4eDd
//split contract deployed at: 0xA221B2f29e19eA64f2DdbD0f7c25aAf7D86C7FC4
//both on rinkeby
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
