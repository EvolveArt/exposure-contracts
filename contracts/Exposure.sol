// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IExposureSeeder.sol";
import "./interfaces/IExposure.sol";
import "./OSContractURI.sol";
import "./Manageable.sol";
import "./ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Exposure is
    ERC2981,
    IExposure,
    OSContractURI,
    Ownable,
    Manageable,
    ERC721Enumerable
{
    using Strings for uint256;
    using BitMaps for BitMaps.BitMap;

    struct Drop {
        address artist;
        uint128 circulating;
        uint128 max;
    }

    event DropCreated(uint256 dropId);

    IExposureSeeder public quantumSeeder;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(uint256 => uint256) public tokenIdToDrop;
    mapping(uint256 => string) public dropToIPFS;

    mapping(uint256 => Drop) private _drops;
    BitMaps.BitMap private _isDropUnpaused;
    uint256 private constant SEPARATOR = 10**4;
    uint256 private _nextDropId;
    string private _baseTokenURI;
    address private _treasury;

    constructor(
        address admin,
        address treasury,
        address seeder
    ) ERC721("Exposure", "EXP") {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _treasury = treasury;
        quantumSeeder = IExposureSeeder(seeder);
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseTokenURI)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _baseTokenURI = baseTokenURI;
    }

    function setContractURI(string calldata uri)
        public
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        super.setContractURI(uri);
    }

    function setRoyalteFee(uint256 fee)
        public
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        royaltyFee = fee;
    }

    function setMinter(address minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, minter);
    }

    function unsetMinter(address minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, minter);
    }

    function setManager(address manager) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MANAGER_ROLE, manager);
    }

    function unsetManager(address manager) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MANAGER_ROLE, manager);
    }

    function setSeeder(address seeder) public onlyRole(DEFAULT_ADMIN_ROLE) {
        quantumSeeder = IExposureSeeder(seeder);
    }

    function createDrop(address artist, uint128 max)
        public
        onlyRole(MANAGER_ROLE)
    {
        require(max < SEPARATOR); //avoid writing over next drop's tokens
        emit DropCreated(_nextDropId);
        _drops[_nextDropId++] = Drop({
            artist: artist,
            max: max,
            circulating: 0
        });
    }

    function setDropIPFS(uint256 dropId, string calldata cid)
        public
        onlyRole(MANAGER_ROLE)
    {
        dropToIPFS[dropId] = cid;
    }

    function unpauseDrop(uint256 dropId, bool shouldUnpause)
        public
        onlyRole(MANAGER_ROLE)
    {
        if (shouldUnpause) _isDropUnpaused.set(dropId);
        else _isDropUnpaused.unset(dropId);
    }

    function mintTo(uint256 dropId, address to)
        public
        override
        onlyRole(MINTER_ROLE)
        returns (uint256)
    {
        require(_isDropUnpaused.get(dropId), "MINT:DROP PAUSED");
        require(
            _drops[dropId].circulating + 1 <= _drops[dropId].max,
            "MINT:DROP MAX REACHED"
        );
        uint256 tokenId = (dropId * SEPARATOR) + (_drops[dropId].circulating++);
        tokenIdToDrop[tokenId] = dropId;
        _safeMint(to, tokenId);
        return tokenId;
    }

    function burn(uint256 tokenId) public override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "BURN:CALLER ISN'T OWNER OR APPROVED"
        );
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        uint256 virtualTokenId = tokenId - (tokenIdToDrop[tokenId] * SEPARATOR);
        uint256 dropId = tokenIdToDrop[tokenId];
        uint256 seed = quantumSeeder.dropIdToSeed(dropId);
        //shuffle metadata
        uint256 shuffledVTI = (virtualTokenId + seed) % _drops[dropId].max;
        if (bytes(dropToIPFS[dropId]).length > 0) {
            return
                string(
                    abi.encodePacked(
                        "ipfs://",
                        dropToIPFS[dropId],
                        "/",
                        shuffledVTI.toString()
                    )
                );
        } else {
            return
                string(
                    abi.encodePacked(
                        _baseURI(),
                        dropId.toString(),
                        "/",
                        shuffledVTI.toString()
                    )
                );
        }
    }

    function getArtist(uint256 dropId) public view override returns (address) {
        return _drops[dropId].artist;
    }

    function royaltyInfo(uint256 tokenId, uint256 salePrice)
        public
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        return (_treasury, (salePrice * royaltyFee) / 10000);
    }

    function drops(uint256 dropId)
        public
        view
        returns (
            address artist,
            uint128 circulating,
            uint128 max,
            bool exists,
            bool paused
        )
    {
        Drop memory drop = _drops[dropId];
        artist = drop.artist;
        circulating = drop.circulating;
        max = drop.max;
        exists = drop.artist != address(0x0) && drop.max != 0;
        paused = !_isDropUnpaused.get(dropId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721Enumerable, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
