// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./AuctionsOA/IAuctionsOA.sol";
import "./SalesOA/ISalesOA.sol";
import "./StorageOA/IStorageOA.sol";

contract OpenArtMarketPlace is ReentrancyGuard {
    address private address_storage;
    address private address_sales;
    address private address_auctions;
    address private owner;

    constructor (address _address_storage, address _address_sales, address _address_auctions){
        address_storage = _address_storage;
        address_sales = _address_sales;
        address_auctions =_address_auctions;
        owner = msg.sender;
    }

    /* Modifier to only allow owner to execute function */
    modifier onlyOwner {
        require(msg.sender == owner, "You are not allowed to execute this method");
        _;
    }

    /* Change storage contract address */
    function setStorageAddress(address _address_storage) onlyOwner public {
        address_storage = _address_storage;
    }

    /* Change sales contract address */
    function setSalesAddress(address _address_sales) onlyOwner public {
        address_sales = _address_sales;
    }

    /* Change auctions contract address */
    function setAuctionsAddress(address _address_auctions) onlyOwner public {
        address_auctions = _address_auctions;
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        return ISalesOA(address_sales).getListingPrice();
    }

    /* Places an item for sale on the marketplace */
    function createMarketItem(address nftContract, uint256 tokenId, bool isActive) public {
        IStorageOA(address_storage).createItem(nftContract, tokenId, isActive, msg.sender);
    }

    /* Creates the sale of a marketplace item */
    function createMarketSale(uint256 itemId) public payable nonReentrant{
        ISalesOA(address_sales).createMarketSale{value: msg.value}(itemId, msg.sender);
    }

    /* Returns all unsold market items */
    function fetchMarketItems() public view returns (IStorageOA.StorageItem[] memory) {
        return IStorageOA(address_storage).getItems();
    }

    /* Return items by collections */
    function fetchCollectionItems(address collectionAddress) public view returns (IStorageOA.StorageItem[] memory) {
        return IStorageOA(address_storage).getItemsByCollection(collectionAddress);
    }

    /* Returns onlyl items that a user has purchased */
    function fetchMyNFTs() public view returns (IStorageOA.StorageItem[] memory) {
        return IStorageOA(address_storage).getItemsByCollection(msg.sender);
    }

       /* Returns only disabled items that user owns */
    function fetchMyDisabledNFTs() public view returns (IStorageOA.StorageItem[] memory) {
        return IStorageOA(address_storage).getDisabledItemsByOwner(msg.sender);
    }

    /* Returns an element by its ID */
    function getItem (uint256 itemId) public view returns (IStorageOA.StorageItem memory) {
        return IStorageOA(address_storage).getItem(itemId);
    }

    /* Put on sale */
    function activateSale(uint256 itemId, uint256 price, address currency) public {
        ISalesOA(address_sales).activateSale(itemId, price, currency, msg.sender);
    }

    /* Remove from sale */
    function deactivateSale(uint256 itemId) public {
        ISalesOA(address_sales).deactivateSale(itemId, msg.sender);
    }

    /* put up for auction */
    function activateAuction(uint256 itemId, uint256 endTime, uint256 minBid, address currency) public {
        IAuctionsOA(address_auctions).activateAuction(itemId, endTime, minBid, currency, msg.sender);
    }

    /* Allow users to bid */
    function bid(uint256 itemId, uint256 bidAmount) public {
        IAuctionsOA(address_auctions).bid(itemId, bidAmount, msg.sender);
    }

    /* Ends auction when time is done and sends the funds to the beneficiary */
    function auctionEnd(uint256 itemId) public {
        IAuctionsOA(address_auctions).auctionEnd(itemId);
    }

    /* Allows user to transfer the earned NFT */
    function collectNFT(uint256 itemId) public {
        IAuctionsOA(address_auctions).collectNFT(itemId, msg.sender);
    }

}