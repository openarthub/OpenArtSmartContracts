// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../utils/ApprovalsGuard.sol";

contract ERC721Royalties is ERC721URIStorage, ApprovalsGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  address private _contractAddress;
  address private _auctionsAddress;
  struct RoyaltyInfo {
    uint256 percent;
    address receiver;
  }
  mapping(uint256 => RoyaltyInfo) private _royaltiesInfo;

  constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

  function createToken(
    string memory tokenURI,
    uint256 royaltiesPercent,
    address royaltiesReceiver
  ) external onlyApprovalsOrOwner returns (uint256) {
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();

    _mint(msg.sender, newItemId);
    _setTokenURI(newItemId, tokenURI);
    _royaltiesInfo[newItemId] = RoyaltyInfo(royaltiesPercent, royaltiesReceiver);
    return newItemId;
  }

  function royaltyInfo(uint256 tokenId_, uint256 salePrice_)
    external
    view
    returns (address receiver, uint256 royaltyAmount)
  {
    RoyaltyInfo memory royalty = _royaltiesInfo[tokenId_];
    uint256 amount = ((salePrice_ * royalty.percent) / 100);
    return (royalty.receiver, amount);
  }
}
