// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface IOffersOA {
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

  /* Allow users to make an offer */
  function makeOffer(
    uint256 itemId,
    uint256 bidAmount,
    address bidder,
    uint256 endTime,
    address currency
  ) external;

  /* Allow item's owner to accept offer and recive his profit */
  function acceptOffer(uint256 offerId, address approval) external;

  /* Allows user to claim items */
  function claimItem(uint256 offerId, address claimer) external;

  /* Returns item's offers */
  function getOffersByItem(uint256 itemId) external view returns (Offer[] memory);

  /* Return item's offers currently active */
  function getActiveOffersByItem(uint256 itemId) external view returns (Offer[] memory);

  /* Set storage address */
  function setStorageAddress(address addressStorage) external;
}
