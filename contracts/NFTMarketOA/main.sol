// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./AuctionsOA/IAuctionsOA.sol";
import "./SalesOA/ISalesOA.sol";
import "./StorageOA/IStorageOA.sol";
import "./OffersOA/IOffersOA.sol";

contract OpenArtMarketPlace is ReentrancyGuard {
  address private _addressStorage;
  address private _addressSales;
  address private _addressAuctions;
  address private _addressOffers;
  address private owner;

  constructor(
    address addressStorage,
    address addressSales,
    address addressAuctions,
    address addressOffers
  ) {
    _addressStorage = addressStorage;
    _addressSales = addressSales;
    _addressAuctions = addressAuctions;
    _addressOffers = addressOffers;
    owner = msg.sender;
  }

  /* Modifier to only allow owner to execute function */
  modifier onlyOwner() {
    require(msg.sender == owner, "You are not allowed to execute this method");
    _;
  }

  /* Change storage contract address */
  function setStorageAddress(address addressStorage) public onlyOwner {
    _addressStorage = addressStorage;
  }

  /* Change sales contract address */
  function setSalesAddress(address addressSales) public onlyOwner {
    _addressSales = addressSales;
  }

  /* Change offers contract address */
  function setOffersAddress(address addressOffers) public onlyOwner {
    _addressOffers = addressOffers;
  }

  /* Change auctions contract address */
  function setAuctionsAddress(address addressAuctions) public onlyOwner {
    _addressAuctions = addressAuctions;
  }

  /* Returns the listing price of the contract */
  function getListingPrice() public view returns (uint256) {
    return ISalesOA(_addressSales).getListingPrice();
  }

  /* Places an item for sale on the marketplace */
  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    bool isActive
  ) public {
    IStorageOA(_addressStorage).createItem(nftContract, tokenId, isActive, msg.sender);
  }

  /* Creates the sale of a marketplace item */
  function createMarketSale(uint256 itemId) public payable nonReentrant {
    ISalesOA(_addressSales).createMarketSale{value: msg.value}(itemId, msg.sender);
  }

  /* Returns all unsold market items */
  function fetchMarketItems() public view returns (IStorageOA.StorageItem[] memory) {
    return IStorageOA(_addressStorage).getItems();
  }

  /* Return items by collections */
  function fetchCollectionItems(address collectionAddress) public view returns (IStorageOA.StorageItem[] memory) {
    return IStorageOA(_addressStorage).getItemsByCollection(collectionAddress);
  }

  /* Returns onlyl items that a user has purchased */
  function fetchMyNFTs() public view returns (IStorageOA.StorageItem[] memory) {
    return IStorageOA(_addressStorage).getItemsByOwner(msg.sender);
  }

  /* Returns only disabled items that user owns */
  function fetchMyDisabledNFTs() public view returns (IStorageOA.StorageItem[] memory) {
    return IStorageOA(_addressStorage).getDisabledItemsByOwner(msg.sender);
  }

  /* Returns an element by its ID */
  function getItem(uint256 itemId) public view returns (IStorageOA.StorageItem memory) {
    return IStorageOA(_addressStorage).getItem(itemId);
  }

  /* Put on sale */
  function activateSale(
    uint256 itemId,
    uint256 price,
    address currency
  ) public {
    ISalesOA(_addressSales).activateSale(itemId, price, currency, msg.sender);
  }

  /* Remove from sale */
  function deactivateSale(uint256 itemId) public {
    ISalesOA(_addressSales).deactivateSale(itemId, msg.sender);
  }

  /* put up for auction */
  function activateAuction(
    uint256 itemId,
    uint256 endTime,
    uint256 minBid,
    address currency
  ) public {
    IAuctionsOA(_addressAuctions).activateAuction(itemId, endTime, minBid, currency, msg.sender);
  }

  /* Allow users to bid */
  function bid(uint256 itemId, uint256 bidAmount) public {
    IAuctionsOA(_addressAuctions).bid(itemId, bidAmount, msg.sender);
  }

  /* Ends auction when time is done and sends the funds to the beneficiary */
  function auctionEnd(uint256 itemId) public {
    IAuctionsOA(_addressAuctions).getProfits(itemId, msg.sender);
  }

  /* Allows user to transfer the earned NFT */
  function collectNFT(uint256 itemId) public {
    IAuctionsOA(_addressAuctions).collectNFT(itemId, msg.sender);
  }

  /* Allow users to make an offer */
  function makeOffer(
    uint256 itemId,
    uint256 bidAmount,
    uint256 endTime,
    address currency
  ) public {
    IOffersOA(_addressOffers).makeOffer(itemId, bidAmount, msg.sender, endTime, currency);
  }

  /* Allow item's owner to accept offer and recive his profit */
  function acceptOffer(uint256 offerId) public {
    IOffersOA(_addressOffers).acceptOffer(offerId, msg.sender);
  }

  /* Allows user to claim items */
  function claimItem(uint256 offerId) public {
    IOffersOA(_addressOffers).claimItem(offerId, msg.sender);
  }

  /* Returns item's offers */
  function getOffersByItem(uint256 itemId) public view returns (IOffersOA.Offer[] memory) {
    return IOffersOA(_addressOffers).getOffersByItem(itemId);
  }

  /* Return item's offers currently active */
  function getActiveOffersByItem(uint256 itemId) public view returns (IOffersOA.Offer[] memory) {
    return IOffersOA(_addressOffers).getActiveOffersByItem(itemId);
  }
}
