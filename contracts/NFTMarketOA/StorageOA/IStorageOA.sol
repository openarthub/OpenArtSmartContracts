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
    }

    // Method to get all actives items
    function getItems() external returns (StorageItem[] memory);

    // Method to get actives items by collection
    function getItemsByCollection(address collectionAddress) external view returns (StorageItem[] memory);

    // Method to get items by owner
    function getItemsByOwner(address address_owner) external view returns (StorageItem[] memory);

    // Method to get disabled items by owner
    function getDisabledItemsByOwner (address address_owner) external view returns (StorageItem[] memory);

    function getItem (uint256 itemId) external view returns (StorageItem memory);

    function approvalForTransfer(address addressContract, bool approved) external;

    /* Allows other contract to send this contract's nft */
    function transferItem(uint256 itemId, address to) external;

    function setItem(uint256 itemId, address payable owner_item, uint256 price, bool onAuction, bool onSale, uint256 endTime, address highestBidder, uint256 highestBid, address currency, bool isActive, address stored) external;
    function setItemAuction(uint256 itemId, address highestBidder, uint256 highestBid) external;
    function createItem(address nftContract, uint256 tokenId, bool isActive, address owner_item) external;
    function setActiveItem(uint256 itemId, bool isActive) external;
}