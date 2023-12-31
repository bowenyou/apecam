// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

contract ApeCam is ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    uint256 lastMintedBlock;
    uint256 minPrice;
    mapping(uint256 => uint256) public prevPrice;
    address apecoin;

    constructor(address _apecoin, uint256 _minPrice) ERC721("ApeCam", "ACAM") {
        apecoin = _apecoin;
        minPrice = _minPrice;
    }

    function mint(address recipient, string memory _tokenURI) public returns (uint256) {
        require(lastMintedBlock < block.number);

        uint256 newId = _tokenIds.current();
        _mint(recipient, newId);
        _setTokenURI(newId, _tokenURI);
        lastMintedBlock = block.number;
        prevPrice[newId] = minPrice;

        _tokenIds.increment();

        return newId;
    }

    function steal(uint256 tokenId, uint256 amount) public {
        address owner = ownerOf(tokenId);
        require(msg.sender != owner, "cannot steal from yourself");
        require(amount > prevPrice[tokenId], "must pay more than previous person to steal");

        prevPrice[tokenId] = amount;

        _transfer(owner, msg.sender, tokenId);
        IERC20(apecoin).transferFrom(msg.sender, owner, amount);
    }

    function getOwnedTokenIds(address wallet) external view returns (uint256[] memory) {
        uint256 balance = balanceOf(wallet);
        uint256[] memory ids = new uint256[](balance);

        for (uint256 i = 0; i < balance; i++) {
            ids[i] = IERC721Enumerable(this).tokenOfOwnerByIndex(wallet, i);
        }
        return ids;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }
}
