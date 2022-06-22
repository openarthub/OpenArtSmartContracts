// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../StorageOA/IStorageOA.sol";
import "../../utils/ApprovalsGuard.sol";
import "../Events/IEvents.sol";

contract OffersOA is ReentrancyGuard, ApprovalsGuard, IEvents {
  using Counters for Counters.Counter;
  Counters.Counter private _offerIds;
  address private _addressStorage;
  uint256 private _listingPrice;

  /* Struct to save if user has money to collect */
  struct Offer {
    uint256 offerId;
    uint256 itemId;
    uint256 amount;
    address bidder;
    address currency;
    uint256 endTime;
    bool accepted;
    bool collected;
  }

  mapping(uint256 => Offer) private offers;

  constructor(uint256 listingPrice, address addressStorage) {
    _listingPrice = listingPrice;
    _addressStorage = addressStorage;
  }

  /* Allow users to make an offer */
  function makeOffer(
    uint256 itemId,
    uint256 bidAmount,
    address bidder,
    uint256 endTime,
    address currency
  ) external onlyApprovals {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);

    require(!item.onAuction, "This item is currently on auction");
    require(item.owner != bidder, "You are the owner of this nft");
    require((bidAmount > 0), "Amount must be greater than 0");

    _offerIds.increment();
    uint256 offerId = _offerIds.current();

    offers[offerId] = Offer(offerId, itemId, bidAmount, bidder, currency, endTime, false, false);

    emit MakeOffer(bidder, item.owner, itemId, item.nftContract, item.tokenId, bidAmount, endTime, block.timestamp);
  }

  /* Allow item's owner to accept offer and recive his profit */
  function acceptOffer(uint256 offerId, address approval) external onlyApprovals nonReentrant {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(offers[offerId].itemId);

    require(item.owner == approval, "You are not the owner of this item");
    require(!item.onAuction, "You can not accept offer because the item is currently on auction");
    Offer memory offer = offers[offerId];
    require(block.timestamp < offer.endTime, "The offer has already expired");
    require(!offer.accepted, "The offer has already been accepted");
    require(!offer.collected, "Item was already collected");

    IERC20 erc20 = IERC20(offers[offerId].currency);
    if (item.stored == address(0)) {
      IERC721(item.nftContract).transferFrom(item.owner, _addressStorage, item.tokenId);
    }

    require(
      erc20.transferFrom(offer.bidder, address(this), offer.amount),
      "Error at make transaction."
    );
    require(
      erc20.transfer(item.owner, (offer.amount - ((offer.amount * _listingPrice) / 100))),
      "Transfer to owner failed"
    );
    require(erc20.transfer(owner, ((offer.amount * _listingPrice) / 100)), "Transfer failed");
    offers[offerId].accepted = true;
    iStorage.setItem(
      item.itemId,
      payable(offer.bidder),
      item.price,
      item.onAuction,
      item.onSale,
      item.endTime,
      item.highestBidder,
      item.highestBid,
      item.currency,
      item.isActive,
      item.stored
    );

    emit SaleItem(offer.bidder, item.owner, item.itemId, item.nftContract, item.tokenId, offer.amount, block.timestamp);
  }

  /* Allows user to claim items */
  function claimItem(uint256 offerId, address claimer) external onlyApprovals {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(offers[offerId].itemId);
    require(offers[offerId].accepted, "The offer has not been accepted");
    require(claimer == item.owner, "Only the winner can claim the nft.");
    offers[offerId].collected = true;
    iStorage.transferItem(item.itemId, claimer);
  }

  /* Returns item's offers */
  function getOffersByItem(uint256 itemId) external view returns (Offer[] memory) {
    uint256 totalItemCount = _offerIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (offers[i + 1].itemId == itemId) {
        itemCount += 1;
      }
    }

    Offer[] memory items = new Offer[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (offers[i + 1].itemId == itemId) {
        uint256 currentId = i + 1;
        Offer storage currentItem = offers[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Return item's offers currently active */
  function getActiveOffersByItem(uint256 itemId) external view returns (Offer[] memory) {
    uint256 totalItemCount = _offerIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (offers[i + 1].itemId == itemId && block.timestamp < offers[i + 1].endTime) {
        itemCount += 1;
      }
    }

    Offer[] memory items = new Offer[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (offers[i + 1].itemId == itemId && block.timestamp < offers[i + 1].endTime) {
        uint256 currentId = i + 1;
        Offer storage currentItem = offers[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Set storage address */
  function setStorageAddress(address addressStorage) public onlyOwner {
    _addressStorage = addressStorage;
  }
}
