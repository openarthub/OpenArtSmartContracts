// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";
import "../utils/ApprovalsGuardDynamicOwner.sol";

contract AEIOU is ERC721A, ApprovalsGuardDynamicOwner {
  string private baseURI;
  uint256 private _revelationTime;
  string private _hiddenURI = "https://ipfs.io/ipfs/QmdGusNysZzsQs6XAmPfgDwmYz65cgdayCyxksN746X3Xh/";

  struct RoyaltyInfo {
    uint256 percent;
    address receiver;
  }
  mapping(uint256 => RoyaltyInfo) private _royaltiesInfo;

  constructor(
    string memory name_,
    string memory symbol_,
    address owner_,
    uint256 maxSupply_,
    string memory baseURI_,
    uint256 revelationTime_
  ) ERC721A(name_, symbol_) ApprovalsGuardDynamicOwner(owner_) {
    setApproval(msg.sender, true);
    baseURI = baseURI_;
    _mint(msg.sender, maxSupply_);
    _revelationTime = revelationTime_;
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

  function _baseURI() internal view override returns (string memory) {
    if (_revelationTime > block.timestamp)
      if (_revelationTime > 0) return _hiddenURI;
    return baseURI;
  }

  function setRevelTime(uint256 revelationTime_) external onlyManagerOrOwner {
    _revelationTime = revelationTime_;
  }

  function setHiddenURI(string memory uri_) external onlyManagerOrOwner {
    _hiddenURI = uri_;
  }
}
