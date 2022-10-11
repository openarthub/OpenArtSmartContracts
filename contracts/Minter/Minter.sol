// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../utils/ApprovalsGuard.sol";
import "../ERC721OA/IERC721Royalties.sol";
import "../NFTMarketOA/StorageOA/IStorageOATrusted.sol";

contract Minter is ApprovalsGuard {
  address private _storage;

  constructor(address minterWallet, address storageAddress) {
    _storage = storageAddress;
    setApproval(minterWallet, true);
  }

  struct MintData {
    address contractAddress;
    string urlAsset;
    bool onSale;
    bool onAuction;
    bool isActive;
    address firstOwner;
    uint256 endTime;
    address currency;
    uint256 price;
    address highestBidder;
    uint256 highestBid;
    address royaltiesReceiver;
    uint256 royaltiesPercent;
    bool useRoyalties;
  }

  function mint(MintData memory mintData) external onlyApprovals {
    IERC721Royalties erc721 = IERC721Royalties(mintData.contractAddress);
    uint256 tokenId;
    if (mintData.useRoyalties) {
      tokenId = erc721.createToken(mintData.urlAsset, mintData.royaltiesPercent, mintData.royaltiesReceiver);
    } else {
      tokenId = erc721.createToken(mintData.urlAsset);
    }
    IStorageOA(_storage).trustedCreateItem(
      mintData.contractAddress,
      tokenId,
      mintData.isActive,
      mintData.firstOwner,
      mintData.onSale,
      mintData.onAuction,
      mintData.endTime,
      mintData.currency,
      mintData.price,
      mintData.highestBidder,
      mintData.highestBid
    );
    erc721.transferFrom(address(this), _storage, tokenId);
  }

  function setStorageAddress(address storageAddress_) external onlyOwner {
    _storage = storageAddress_;
  }

  /* Events from external contracts */
  event ItemCreated(uint256 indexed itemId, address indexed nftContract, uint256 indexed tokenId, address owner);
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
}
