// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IExposure {
    function mintTo(uint256 dropId, address artist) external returns (uint256);

    function burn(uint256 tokenId) external;

    function getArtist(uint256 dropId) external view returns (address);
}

interface IExposureBalance is IExposure {
    function balanceOf(address user) external view returns (uint256);
}
