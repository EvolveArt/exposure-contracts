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

  const MintPass = await ethers.getContractFactory("ExposureMintPass");
  const mintPass = await MintPass.deploy(
    "ar://",
    "0xDD523AB1b6016eBe28DA8B68A9585173BB2aAc3F"
  );
  await mintPass.deployed();
  console.log("Mint Pass deployed to:", mintPass.address);

  const SalePlatorm = await ethers.getContractFactory("SalePlatform");
  const salePlatorm = await SalePlatorm.deploy(
    "0x2E19da5a8C5445937ff0BA0D03984Cb756C774A3",
    mintPass.address,
    "0xDD523AB1b6016eBe28DA8B68A9585173BB2aAc3F",
    "0xDD523AB1b6016eBe28DA8B68A9585173BB2aAc3F"
  );
  await salePlatorm.deployed();
  console.log("Sale Platform deployed to:", salePlatorm.address);

  const exposure = await ethers.getContractAt(
    "Exposure",
    "0x2E19da5a8C5445937ff0BA0D03984Cb756C774A3"
  );

  await exposure.setMinter(salePlatorm.address);
  await exposure.setManager("0xDD523AB1b6016eBe28DA8B68A9585173BB2aAc3F");
  await exposure.setManager("0x2AF26B9d454be3768DdD62574738aAd05654C181");
  await exposure.setManager("0x25D2E7509fE39A25819fAd4a31A1512e206fCc1B");
  await salePlatorm.setManager("0xDD523AB1b6016eBe28DA8B68A9585173BB2aAc3F");
  await salePlatorm.setManager("0x2AF26B9d454be3768DdD62574738aAd05654C181");
  await salePlatorm.setManager("0x25D2E7509fE39A25819fAd4a31A1512e206fCc1B");

  console.log("Managers and Minters set.");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
