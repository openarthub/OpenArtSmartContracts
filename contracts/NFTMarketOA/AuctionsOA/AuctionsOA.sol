// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "../../ERC721OA/IERC721OA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../StorageOA/IStorageOA.sol";
import "../../utils/ApprovalsGuard.sol";
import "../Events/IEvents.sol";

contract AuctionsOA is ReentrancyGuard, ApprovalsGuard, IEvents {
  address private _addressStorage;
  uint256 private _listingPrice;

  /* Struct to save if user has money to collect */
  struct Collect {
    bool collected;
    uint256 amount;
    address currency;
    uint256 endTime;
  }

  mapping(uint256 => mapping(address => Collect)) private collects;

  constructor(uint256 listingPrice, address addressStorage) {
    _listingPrice = listingPrice;
    _addressStorage = addressStorage;
  }

  /* Activate Auction */
  function activateAuction(
    uint256 itemId,
    uint256 endTime,
    uint256 minBid,
    address currency,
    address seller
  ) external onlyApprovals {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);

    IERC721 erc721 = IERC721(item.nftContract);
    address itemOwner = erc721.ownerOf(item.tokenId);

    require(seller == itemOwner, "You are not owner of this nft");
    require(!item.onSale, "This item is currently on sale");
    require(!item.onAuction, "This item is already on auction");
    erc721.transferFrom(itemOwner, _addressStorage, item.tokenId);
    item.owner = payable(seller);
    item.price = minBid;
    item.onAuction = true;
    item.onSale = false;
    item.endTime = endTime;
    item.highestBidder = seller;
    item.highestBid = 0;
    item.currency = currency;
    item.stored = _addressStorage;
    iStorage.setItem(itemId, item);
    collects[itemId][seller] = Collect(false, 0, currency, endTime);
    emit ListItem(seller, address(0), itemId, item.nftContract, item.tokenId, minBid, currency);
  }

  /* Allow users to bid */
  function bid(
    uint256 itemId,
    uint256 bidAmount,
    address bidder
  ) external onlyApprovals nonReentrant {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);

    require(block.timestamp < item.endTime, "The auction has already ended");
    require(item.owner != bidder, "You are the owner of this nft");
    require(
      (bidAmount > item.highestBid && item.highestBid > 0) || (bidAmount >= item.price && item.highestBid == 0),
      "There is already a higher or equal bid"
    );

    IERC20 erc20 = IERC20(item.currency);
    require(erc20.transferFrom(bidder, address(this), bidAmount), "Transaction failed at get bid");

    // Withdraw outbided auction
    if (item.highestBidder != address(0)) {
      require(erc20.transfer(item.highestBidder, item.highestBid), "Transfer failed");
    }

    // Set new bid for current item

    iStorage.setItemAuction(itemId, bidder, bidAmount);

    collects[itemId][item.owner].amount = bidAmount;

    emit MakeOffer(bidder, item.owner, itemId, item.nftContract, item.tokenId, bidAmount, item.endTime, item.currency);
  }

  /* Ends auction when time is done and sends the funds to the beneficiary */
  function getProfits(uint256 itemId, address collector) external onlyApprovals nonReentrant {
    Collect memory collect = collects[itemId][collector];
    require(block.timestamp > collect.endTime, "The auction has not ended yet");
    require(!collect.collected, "The function getProfit has already been called");
    require(collect.amount > 0, "Item didn't had bids");

    IERC20 erc20 = IERC20(collect.currency);

    address royaltiesReceiver;
    uint256 royaltiesAmount;
    IStorageOA.StorageItem memory item = IStorageOA(_addressStorage).getItem(itemId);
    try IERC721OA(item.nftContract).royaltyInfo(item.tokenId, item.price) returns (
      address receiver,
      uint256 royaltyAmount
    ) {
      royaltiesReceiver = receiver;
      royaltiesAmount = royaltyAmount;
    } catch {}
    if (royaltiesAmount > 0) {
      require(erc20.transfer(royaltiesReceiver, royaltiesAmount), "Transfer failed");
    }
    if (collector == owner) {
      require(erc20.transfer(owner, collect.amount - royaltiesAmount), "Transfer failed");
    } else {
      require(
        erc20.transfer(collector, (collect.amount - ((collect.amount * _listingPrice) / 100) - royaltiesAmount)),
        "Transfer to owner failed"
      );
      require(erc20.transfer(owner, ((collect.amount * _listingPrice) / 100)), "Transfer failed");
    }

    collects[itemId][collector].collected = true;
  }

  /* Allows user to transfer the earned NFT */
  function collectNFT(uint256 itemId, address winner) external onlyApprovals {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
    require(block.timestamp > item.endTime, "The auction has not ended yet");
    require(winner == item.highestBidder, "Only the winner can claim the nft.");
    iStorage.transferItem(itemId, winner);
    emit SaleItem(item.owner, winner, itemId, item.nftContract, item.tokenId, item.highestBid, item.currency);
  }

  /* Set storage address */
  function setStorageAddress(address addressStorage) public onlyOwner {
    _addressStorage = addressStorage;
  }

  /* Get collects of user */
  function getCollectItem(uint256 itemId, address sender) external view onlyApprovals returns (Collect memory) {
    return collects[itemId][sender];
  }
}
