// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../StorageOA/IStorageOA.sol";
import "../../utils/ApprovalsGuard.sol";

contract AuctionsOA is ApprovalsGuard {
  address address_storage;
  uint256 listingPrice;

  /* Struct to save if user has money to collect */
  struct Collect {
    bool collected;
    uint256 amount;
    address currency;
    uint256 endTime;
  }

  mapping(uint256 => mapping(address => Collect)) private collects;

  constructor(uint256 _listingPrice, address _address_storage) {
    listingPrice = _listingPrice;
    address_storage = _address_storage;
  }

  event MakeOffer(
    uint256 indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address owner,
    address bidder,
    uint256 amount,
    uint256 endTime
  );

  event ListItem(
    uint256 indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address owner,
    uint256 price
  );

  /* Activate Auction */
  function activateAuction(
    uint256 itemId,
    uint256 endTime,
    uint256 minBid,
    address currency,
    address seller
  ) public onlyApprovals {
    IStorageOA iStorage = IStorageOA(address_storage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);

    require(seller == item.owner, "You are not owner of this nft");
    require(!item.onSale, "This item is currently on sale");
    require(!item.onAuction, "This item is already on auction");
    IERC721(item.nftContract).transferFrom(item.owner, address_storage, item.tokenId);
    iStorage.setItem(itemId, payable(seller), minBid, true, false, endTime, seller, 0, currency, true, address_storage);
    collects[itemId][seller] = Collect(false, 0, currency, endTime);
    emit ListItem(itemId, item.nftContract, item.tokenId, seller, minBid);
  }

  /* Allow users to bid */
  function bid(
    uint256 itemId,
    uint256 bidAmount,
    address bidder
  ) public onlyApprovals {
    IStorageOA iStorage = IStorageOA(address_storage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);

    require(block.timestamp < item.endTime, "The auction has already ended");
    require(item.owner != bidder, "You are the owner of this nft");
    require(
      (bidAmount > item.highestBid) || (bidAmount >= item.price && item.highestBid == 0),
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

    emit MakeOffer(itemId, item.nftContract, item.tokenId, item.owner, bidder, bidAmount, item.endTime);
  }

  /* Ends auction when time is done and sends the funds to the beneficiary */
  function getProfits(uint256 itemId, address collector) public onlyApprovals {
    require(block.timestamp > collects[itemId][collector].endTime, "The auction has not ended yet");
    require(!collects[itemId][collector].collected, "The function auctionEnd has already been called");
    require(collects[itemId][collector].amount > 0, "Item didn't had bids");

    IERC20 erc20 = IERC20(collects[itemId][collector].currency);

    if (collector == owner) {
      require(erc20.transfer(owner, collects[itemId][collector].amount), "Transfer failed");
    } else {
      require(
        erc20.transfer(
          collector,
          (collects[itemId][collector].amount - ((collects[itemId][collector].amount * listingPrice) / 100))
        ),
        "Transfer to owner failed"
      );
      require(erc20.transfer(owner, ((collects[itemId][collector].amount * listingPrice) / 100)), "Transfer failed");
    }

    collects[itemId][collector].collected = true;
  }

  /* Allows user to transfer the earned NFT */
  function collectNFT(uint256 itemId, address winner) public onlyApprovals {
    IStorageOA iStorage = IStorageOA(address_storage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
    require(winner == item.highestBidder, "Only the winner can claim the nft.");
    iStorage.transferItem(itemId, winner);
  }

  /* Set storage address */
  function setStorageAddress(address _address_storage) public onlyOwner {
    address_storage = _address_storage;
  }
}
