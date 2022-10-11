// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../utils/ApprovalsGuardDynamicOwner.sol";

contract Collection is ERC721, ApprovalsGuardDynamicOwner {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  address private _contractAddress;
  address private _auctionsAddress;
  uint256 private _maxSupply;
  string private baseURI;
  uint256 private _revelTime;

  struct RoyaltyInfo {
    uint256 percent;
    address receiver;
  }
  mapping(uint256 => RoyaltyInfo) private _royaltiesInfo;

  constructor(
    string memory _name,
    string memory _symbol,
    address owner_,
    uint256 maxSupply_,
    string memory baseURI_,
    uint256 revelTime_
  ) ERC721(_name, _symbol) ApprovalsGuardDynamicOwner(owner_) {
    _maxSupply = maxSupply_;
    _setApproval(msg.sender, true);
    baseURI = baseURI_;
    _revelTime = revelTime_;
  }

  function createToken(uint256 royaltiesPercent, address royaltiesReceiver) external payable returns (uint256) {
    require(_tokenIds.current() < _maxSupply, "Collection has reached max supply.");
    require(msg.value == 0.1 ether, "Price no covered");
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();

    _mint(msg.sender, newItemId);
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

  function _baseURI() internal view override returns (string memory) {
    return baseURI;
  }

  function setRevelTime(uint256 revelTime_) external onlyManagerOrOwner {
    _revelTime = revelTime_;
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    if (_revelTime > block.timestamp && _revelTime > 0) {
      return "https://ipfs.io/ipfs/QmXCKSdNzgTUkKb9g6S7qhbp1jT8J6FcFAu7uPTMrTU5YN";
    }
    return super.tokenURI(tokenId);
  }
}
