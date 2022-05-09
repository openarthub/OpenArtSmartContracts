// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface INFTMarketOA {
    struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable owner;
        uint256 price;
        bool sold;
        bool onAuction;
        bool onSale;
        uint256 endTime;
        address highestBidder;
        uint highestBid;
        address currency;
        bool isActive;
    }
    function myallowance(address currency) view external returns (uint);
    function getListingPrice() external view returns (uint256);
    function createMarketItem(address nftContract, uint256 tokenId, bool isActive) external;
    function createMarketSale(address nftContract, uint256 itemId) external payable;
    function fetchMarketItems() external returns (MarketItem[] memory);
    function fetchCollectionItems(address collectionAddress) external returns (MarketItem[] memory);
    function fetchMyNFTs() external view returns (MarketItem[] memory);
    function fetchMyDisabledNFTs() external view returns (MarketItem[] memory);
    function fetchMyActiveNFTs() external view returns (MarketItem[] memory);
    function fetchItemsCreated() external view returns (MarketItem[] memory);
    function getItem (uint256 itemId) external view returns (MarketItem memory);
    function setListingPrice (uint percent) external;
    function activateSale(uint256 itemId, uint256 price, address currency) external;
    function deactivateSale(uint256 itemId) external;
    function activateAuction(uint256 itemId, uint256 endTime, uint256 minBid, address currency) external;
    function bid(uint256 itemId, uint256 bidAmount) external;
    function auctionEnd(uint256 itemId) external;
    function collectNFT(address nftContract, uint256 itemId) external;
    function approvalForTransfer(address addressContract) external;
    function transferNFT(address nftContract, address to, uint256 nftId) external;
    function setActiveItem(uint256 itemId, bool isActive) external;
}