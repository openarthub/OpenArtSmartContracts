// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../utils/ApprovalsGuardDynamicOwner.sol";

contract FOLEARTMX is ERC721URIStorage, ApprovalsGuardDynamicOwner {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  address private _contractAddress;
  address private _auctionsAddress;
  uint256 private _maxSupply;

  struct RoyaltyInfo {
    uint256 percent;
    address receiver;
  }
  mapping(uint256 => RoyaltyInfo) private _royaltiesInfo;

  constructor(
    string memory _name,
    string memory _symbol,
    address owner_,
    uint256 maxSupply_
  ) ERC721(_name, _symbol) ApprovalsGuardDynamicOwner(owner_) {
    _maxSupply = maxSupply_;
    _setApproval(msg.sender, true);
  }

  function createToken(
    string memory tokenURI,
    uint256 royaltiesPercent,
    address royaltiesReceiver
  ) external onlyApprovalsOrOwner returns (uint256) {
    require(_tokenIds.current() < _maxSupply, "Collection has reached max supply.");
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

  function totalSupply() external view returns (uint256) {
    return _tokenIds.current();
  }

  function maxSupply() external view returns (uint256) {
    return _maxSupply;
  }
}
