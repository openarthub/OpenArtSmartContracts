// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface IAuctionsOA {

    function activateAuction(uint256 itemId, uint256 endTime, uint256 minBid, address currency, address seller) external;
    /* Allow users to bid */
    function bid(uint256 itemId, uint256 bidAmount, address bidder) external;

    /* Ends auction when time is done and sends the funds to the beneficiary */
    function getProfits(uint256 itemId, address collector) external;

    /* Allows user to transfer the earned NFT */
    function collectNFT(uint256 itemId, address winner) external;
}