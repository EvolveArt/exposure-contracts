// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IExposureSeeder {
    function dropIdToSeed(uint256 dropId) external view returns (uint256);
}
