// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  const Seeder = await ethers.getContractFactory("BogusSeeder");
  const seeder = await Seeder.deploy();
  await seeder.deployed();
  console.log("Seeder deployed to:", seeder.address);

  const Exposure = await ethers.getContractFactory("Exposure");
  const exposure = await Exposure.deploy(
    "0xDD523AB1b6016eBe28DA8B68A9585173BB2aAc3F",
    "0xDD523AB1b6016eBe28DA8B68A9585173BB2aAc3F",
    seeder.address
  );

  await exposure.deployed();

  console.log("Exposure deployed to:", exposure.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
