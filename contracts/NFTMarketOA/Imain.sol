// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./AuctionsOA/IAuctionsOA.sol";
import "./SalesOA/ISalesOA.sol";
import "./StorageOA/IStorageOA.sol";
import "./OffersOA/IOffersOA.sol";

interface IOpenArtMarketPlace {
  /* Change storage contract address */
  function setStorageAddress(address addressStorage) external;

  /* Change sales contract address */
  function setSalesAddress(address addressSales) external;

  /* Change offers contract address */
  function setOffersAddress(address addressOffers) external;

  /* Change auctions contract address */
  function setAuctionsAddress(address addressAuctions) external;

  /* Returns the listing price of the contract */
  function getListingPrice() external view returns (uint256);

  /* Places an item for sale on the marketplace */
  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    bool isActive,
    bool onSale,
    bool onAuction,
    uint256 endTime,
    address currency,
    uint256 price
  ) external;

  /* Creates the sale of a marketplace item */
  function createMarketSale(uint256 itemId) external payable;

  /* Returns all unsold market items */
  function fetchMarketItems() external view returns (IStorageOA.StorageItem[] memory);

  /* Return items by collections */
  function fetchCollectionItems(address collectionAddress) external view returns (IStorageOA.StorageItem[] memory);

  /* Returns onlyl items that a user has purchased */
  function fetchMyNFTs() external view returns (IStorageOA.StorageItem[] memory);

  /* Returns only disabled items that user owns */
  function fetchMyDisabledNFTs() external view returns (IStorageOA.StorageItem[] memory);

  /* Returns an element by its ID */
  function getItem(uint256 itemId) external view returns (IStorageOA.StorageItem memory);

  /* Put on sale */
  function activateSale(
    uint256 itemId,
    uint256 price,
    address currency
  ) external;

  /* Remove from sale */
  function deactivateSale(uint256 itemId) external;

  /* put up for auction */
  function activateAuction(
    uint256 itemId,
    uint256 endTime,
    uint256 minBid,
    address currency
  ) external;

  /* Allow users to bid */
  function bid(uint256 itemId, uint256 bidAmount) external;

  /* Ends auction when time is done and sends the funds to the beneficiary */
  function auctionEnd(uint256 itemId) external;

  /* Allows user to transfer the earned NFT */
  function collectNFT(uint256 itemId) external;

  /* Allow users to make an offer */
  function makeOffer(
    uint256 itemId,
    uint256 bidAmount,
    uint256 endTime,
    address currency
  ) external;

  /* Allow item's owner to accept offer and recive his profit */
  function acceptOffer(uint256 offerId) external;

  /* Allows user to claim items */
  function claimItem(uint256 offerId) external;

  /* Returns item's offers */
  function getOffersByItem(uint256 itemId) external view returns (IOffersOA.Offer[] memory);

  /* Return item's offers currently active */
  function getActiveOffersByItem(uint256 itemId) external view returns (IOffersOA.Offer[] memory);

  /* Get collects of user */
  function getCollectItem(uint256 itemId, address sender) external view returns (IAuctionsOA.Collect memory);

  /* Collect profit */
  function collectProfit(uint256 itemId) external;
}
