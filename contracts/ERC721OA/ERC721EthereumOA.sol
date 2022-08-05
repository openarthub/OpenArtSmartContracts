// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTEth is ERC721URIStorage, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  address private _contractAddress;
  address private _auctionsAddress;

  constructor(address salesAddress, address auctionsAddress) ERC721("Metaverse", "METT") {
    _contractAddress = salesAddress;
    _auctionsAddress = auctionsAddress;
  }

  function createToken(string memory tokenURI) public returns (uint256) {
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();

    _mint(msg.sender, newItemId);
    _setTokenURI(newItemId, tokenURI);
    setApprovalForAll(_contractAddress, true);
    setApprovalForAll(_auctionsAddress, true);
    return newItemId;
  }
}
