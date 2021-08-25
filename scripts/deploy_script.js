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
//stakeToken deployed at: 0x72E0f4fE079fD507b0d9244427B5bEf5c46e79cb
//split contract deployed at: 0x6FBC1f0cdA6C538e2Ac8ce71C26d1F974efD7305
//both on rinkeby
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
