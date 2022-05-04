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
    "0xAeEfFA0865eCD9F2d44b507C78149F92Fa48f904",
    "0xAeEfFA0865eCD9F2d44b507C78149F92Fa48f904",
    seeder.address
  );

  await exposure.deployed();

  console.log("Exposure deployed to:", exposure.address);
}
// Seeder deployed to: 0x2D7FCA6e92eF68C2d0759aD2a7798bF0E3242F4C
// Exposure deployed to: 0x136c84322fcb716Aa4454d6Cca0970DB69feaa6a

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
