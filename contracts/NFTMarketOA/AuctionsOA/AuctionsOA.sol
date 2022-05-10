// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../StorageOA/IStorageOA.sol";
import "../../utils/ApprovalsGuard.sol";



contract AuctionsOA is ApprovalsGuard {

    address address_storage;
    uint256 listingPrice;

    constructor(uint256 _listingPrice, address _address_storage) {
        listingPrice = _listingPrice;
        address_storage = _address_storage;
    }

    /* Activate Auction */
    function activateAuction(uint256 itemId, uint256 endTime, uint256 minBid, address currency, address seller) onlyApprovals public {
        IStorageOA iStorage = IStorageOA(address_storage);
        IStorageOA.StorageItem memory item = iStorage.getItem(itemId);

        require(seller == item.owner, "You are not owner of this nft");
        require(!item.onSale, "This item is currently on sale");
        require(!item.onAuction, "This item is already on auction");        
        IERC721(item.nftContract).transferFrom(item.owner, address_storage, item.tokenId);
        iStorage.setItem(itemId, payable(seller), minBid, true, false, endTime, address(0), 0, currency, true, address_storage);
    }

    /* Allow users to bid */
    function bid(uint256 itemId, uint256 bidAmount, address bidder) onlyApprovals public {
        IStorageOA iStorage = IStorageOA(address_storage);
        IStorageOA.StorageItem memory item = iStorage.getItem(itemId);

        require(item.onAuction, "This item is not currently on auction.");
        require(block.timestamp < item.endTime, "The auction has already ended");
        require(item.owner != bidder, "You are the owner of this nft");

        require((bidAmount > item.highestBid) || (bidAmount >= item.price && item.highestBid == 0), "There is already a higher or equal bid");

        IERC20 erc20 = IERC20(item.currency);
        require(erc20.transferFrom(bidder, address(this), bidAmount), "Transaction failed at get bid"); // Hold OARTs

        // Withdraw outbided auction
        if(item.highestBidder != address(0)) {
            require(erc20.transfer(item.highestBidder, item.highestBid), "Transfer failed");
        }

        // Set new bid for current item
        iStorage.setItemAuction(itemId, bidder, bidAmount);
    }

    /* Ends auction when time is done and sends the funds to the beneficiary */
    function auctionEnd(uint256 itemId) onlyApprovals public {
        IStorageOA iStorage = IStorageOA(address_storage);
        IStorageOA.StorageItem memory item = iStorage.getItem(itemId);

        if(block.timestamp < item.endTime) {
            revert("The auction has not ended yet");
        }

        if(!item.onAuction){
            revert("The function auctionEnd has already been called");
        }

        IERC20 erc20 = IERC20(item.currency);

        item.onAuction = false;
        if (item.owner == owner) {
            require(erc20.transfer(owner, item.highestBid), "Transfer failed");
        } else {
            require(erc20.transfer(item.owner, (item.highestBid - (item.highestBid * listingPrice / 100))), "Transfer to owner failed");
            require(erc20.transfer(owner, (item.highestBid * listingPrice / 100)), "Transfer failed");
        }
    }

    /* Allows user to transfer the earned NFT */
    function collectNFT(uint256 itemId, address winner) onlyApprovals public {
        IStorageOA iStorage = IStorageOA(address_storage);
        IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
        require(winner == item.highestBidder, "Only the winner can claim the nft.");
        iStorage.transferItem(itemId, winner);
    }

    /* Set storage address */
    function setStorageAddress (address _address_storage) onlyOwner public {
        address_storage = _address_storage;
    }
}