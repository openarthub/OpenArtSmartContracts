// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../NFTMarketOA/INFTMarketOA.sol";
import "../../utils/ApprovalsGuard.sol";
import "hardhat/console.sol";

contract StorageOA is ApprovalsGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;

  // Address allowed to create items without owner verification
  address private _trustedAddress;

  // Structur of items stored
  struct StorageItem {
    uint256 itemId;
    address nftContract;
    uint256 tokenId;
    address payable owner;
    uint256 price;
    bool onAuction;
    bool onSale;
    uint256 endTime;
    address highestBidder;
    uint256 highestBid;
    address currency;
    bool isActive;
    address stored;
  }

  mapping(uint256 => StorageItem) private storedItems;

  constructor(address addressBackup) {
    console.log("Address Backup %s", addressBackup);
    if (addressBackup == address(0)) return;
    try INFTMarketOA(addressBackup).fetchMarketItems() returns (INFTMarketOA.MarketItem[] memory oldData) {
      for (uint256 item = 0; item < oldData.length; item++) {
        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        storedItems[itemId] = StorageItem(
          itemId,
          oldData[item].nftContract,
          oldData[item].tokenId,
          payable(oldData[item].owner),
          oldData[item].price,
          oldData[item].onAuction,
          oldData[item].onSale,
          oldData[item].endTime,
          oldData[item].highestBidder,
          oldData[item].highestBid,
          oldData[item].currency,
          oldData[item].isActive,
          address(0)
        );
      }
    } catch {
      return;
    }
  }

  event ItemCreated(uint256 indexed itemId, address indexed nftContract, uint256 indexed tokenId, address owner);

  // Method to get all actives items
  function getItems() external view returns (StorageItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].isActive) {
        itemCount += 1;
      }
    }

    StorageItem[] memory items = new StorageItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].isActive) {
        uint256 currentId = i + 1;
        StorageItem storage currentItem = storedItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  // Method to get actives items by collection
  function getItemsByCollection(address collectionAddress) external view returns (StorageItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].nftContract == collectionAddress && storedItems[i + 1].isActive) {
        itemCount += 1;
      }
    }

    StorageItem[] memory items = new StorageItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].nftContract == collectionAddress && storedItems[i + 1].isActive) {
        uint256 currentId = i + 1;
        StorageItem storage currentItem = storedItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  // Method to get items by owner
  function getItemsByOwner(address addressOwner) external view returns (StorageItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].owner == addressOwner) {
        itemCount += 1;
      }
    }

    StorageItem[] memory items = new StorageItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].owner == addressOwner) {
        uint256 currentId = i + 1;
        StorageItem storage currentItem = storedItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  // Method to get disabled items by owner
  function getDisabledItemsByOwner(address addressOwner) external view onlyApprovals returns (StorageItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].owner == addressOwner && !storedItems[i + 1].isActive) {
        itemCount += 1;
      }
    }

    StorageItem[] memory items = new StorageItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (storedItems[i + 1].owner == addressOwner && !storedItems[i + 1].isActive) {
        uint256 currentId = i + 1;
        StorageItem storage currentItem = storedItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  function getItem(uint256 itemId) public view returns (StorageItem memory) {
    return storedItems[itemId];
  }

  /* Allows other contract to send this contract's nft */
  function transferItem(uint256 itemId, address to) external onlyApprovals {
    address nftContract = storedItems[itemId].nftContract;
    uint256 nftId = storedItems[itemId].tokenId;
    IERC721(nftContract).safeTransferFrom(address(this), to, nftId);
    storedItems[itemId].owner = payable(to);
    storedItems[itemId].onAuction = false;
    storedItems[itemId].onSale = false;
    storedItems[itemId].stored = address(0);
    storedItems[itemId].highestBidder = address(0);
    storedItems[itemId].highestBid = 0;
  }

  function setItem(
    uint256 itemId,
    address payable ownerItem,
    uint256 price,
    bool onAuction,
    bool onSale,
    uint256 endTime,
    address highestBidder,
    uint256 highestBid,
    address currency,
    bool isActive,
    address stored
  ) external onlyApprovals {
    storedItems[itemId].owner = ownerItem;
    storedItems[itemId].price = price;
    storedItems[itemId].onAuction = onAuction;
    storedItems[itemId].onSale = onSale;
    storedItems[itemId].endTime = endTime;
    storedItems[itemId].highestBidder = highestBidder;
    storedItems[itemId].highestBid = highestBid;
    storedItems[itemId].currency = currency;
    storedItems[itemId].isActive = isActive;
    storedItems[itemId].stored = stored;
  }

  function setItemAuction(
    uint256 itemId,
    address highestBidder,
    uint256 highestBid
  ) external onlyApprovals {
    storedItems[itemId].highestBidder = highestBidder;
    storedItems[itemId].highestBid = highestBid;
  }

  function createItem(
    address nftContract,
    uint256 tokenId,
    bool isActive,
    address ownerItem,
    bool onSale,
    bool onAuction,
    uint256 endTime,
    address currency,
    uint256 price
  ) external onlyApprovals {
    require(IERC721(nftContract).ownerOf(tokenId) == ownerItem, "You are not owner of this nft.");
    require(((price > 0 && (onAuction || onSale)) || (!onAuction && !onSale)), "Price must be greater than 0");

    _createItem(
      StorageItem(
        0,
        nftContract,
        tokenId,
        payable(ownerItem),
        price,
        onAuction,
        onSale,
        endTime,
        address(0),
        0,
        currency,
        isActive,
        address(0)
      )
    );
  }

  function trustedCreateItem(
    address nftContract,
    uint256 tokenId,
    bool isActive,
    address ownerItem,
    bool onSale,
    bool onAuction,
    uint256 endTime,
    address currency,
    uint256 price,
    address highestBidder,
    uint256 highestBid
  ) external {
    console.log("Im inside of storage");
    require(msg.sender == _trustedAddress, "You can't execute this function");
    require(((price > 0 && (onAuction || onSale)) || (!onAuction && !onSale)), "Price must be greater than 0");
    _createItem(
      StorageItem(
        0,
        nftContract,
        tokenId,
        payable(ownerItem),
        price,
        onAuction,
        onSale,
        endTime,
        highestBidder,
        highestBid,
        currency,
        isActive,
        address(this)
      )
    );
  }

  function _createItem(StorageItem memory item) private {
    _itemIds.increment();
    uint256 itemId = _itemIds.current();
    storedItems[itemId] = StorageItem(
      itemId,
      item.nftContract,
      item.tokenId,
      payable(item.owner),
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

    emit ItemCreated(itemId, item.nftContract, item.tokenId, item.owner);
  }

  function setTrustedAddress(address trustedAddress) external {
    require(msg.sender == owner, "You're not allowed to execute this function");
    _trustedAddress = trustedAddress;
  }

  function setActiveItem(uint256 itemId, bool isActive) external {
    require(
      msg.sender == owner || msg.sender == storedItems[itemId].owner,
      "You are not allowed to modify this element"
    );
    storedItems[itemId].isActive = isActive;
  }
}
