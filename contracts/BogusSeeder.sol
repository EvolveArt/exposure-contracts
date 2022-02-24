// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IExposureSeeder.sol";

contract BogusSeeder is IExposureSeeder {
    function dropIdToSeed(uint256 dropId)
        public
        view
        override
        returns (uint256)
    {
        return 0;
    }
}
