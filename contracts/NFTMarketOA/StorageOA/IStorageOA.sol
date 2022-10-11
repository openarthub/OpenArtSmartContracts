// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface IStorageOA {
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
    bool firstSold;
  }

  // Method to get all actives items
  function getItems() external view returns (StorageItem[] memory);

  // Method to get actives items by collection
  function getItemsByCollection(address collectionAddress) external view returns (StorageItem[] memory);

  // Method to get items by owner
  function getItemsByOwner(address addressOwner) external view returns (StorageItem[] memory);

  // Method to get disabled items by owner
  function getDisabledItemsByOwner(address addressOwner) external view returns (StorageItem[] memory);

  function getItem(uint256 itemId) external view returns (StorageItem memory);

  /* Allows other contract to send this contract's nft */
  function transferItem(uint256 itemId, address to) external;

  function setItem(uint256 itemId, StorageItem memory item) external;

  function setItemAuction(
    uint256 itemId,
    address highestBidder,
    uint256 highestBid
  ) external;

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
  ) external;

  function setActiveItem(uint256 itemId, bool isActive) external;
}
