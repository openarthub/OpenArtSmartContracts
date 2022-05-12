// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../StorageOA/IStorageOA.sol";
import "../../utils/ApprovalsGuard.sol";



contract OffersOA is ApprovalsGuard {

    using Counters for Counters.Counter;
    Counters.Counter private _offerIds;
    address address_storage;
    uint256 listingPrice;

    /* Struct to save if user has money to collect */
    struct Offer {
        uint256 itemId;
        uint256 amount;
        address bidder;
        address currency;
        uint256 endTime;
        bool accepted;
    }

    mapping (uint256 => Offer) private offers;

    constructor(uint256 _listingPrice, address _address_storage) {
        listingPrice = _listingPrice;
        address_storage = _address_storage;
    }

    event MakeOffer (
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address owner,
        address bidder,
        uint256 amount,
        uint256 endTime
    );



    /* Allow users to make an offer */
    function makeOffer(uint256 itemId, uint256 bidAmount, address bidder, uint256 endTime, address currency) onlyApprovals public {
        IStorageOA iStorage = IStorageOA(address_storage);
        IStorageOA.StorageItem memory item = iStorage.getItem(itemId);

        require(!item.onAuction, "This item is currently on auction");
        require(item.owner != bidder, "You are the owner of this nft");
        require((bidAmount > 0), "Amount must be greater than 0");

        _offerIds.increment();
        uint256 offerId = _offerIds.current();

        offers[offerId] = Offer(itemId, bidAmount, bidder, currency, endTime, false);

        emit MakeOffer(itemId, item.nftContract, item.tokenId, item.owner, bidder, bidAmount, item.endTime);
    }

    /* Allow item's owner to accept offer and recive his profit */
    function AcceptOffer(uint256 offerId, address approval) onlyApprovals public {
        IStorageOA iStorage = IStorageOA(address_storage);
        IStorageOA.StorageItem memory item = iStorage.getItem(offers[offerId].itemId);

        require(item.owner == approval, "You are not the owner of this item");
        require(!item.onAuction, "You can not accept offer because the item is currently on auction");
        require(block.timestamp < offers[offerId].endTime, "The offer has already expired");
        require(!offers[offerId].accepted, "The offer has already been accepted");

        IERC20 erc20 = IERC20(offers[offerId].currency);
        require(erc20.transferFrom(offers[offerId].bidder, address(this), offers[offerId].amount), "Error at make transaction.");
        require(erc20.transfer(item.owner, (offers[offerId].amount - (offers[offerId].amount * listingPrice / 100))), "Transfer to owner failed");
        require(erc20.transfer(owner, (offers[offerId].amount * listingPrice / 100)), "Transfer failed");
        offers[offerId].accepted = true;
        iStorage.setItem(item.itemId, payable(offers[offerId].bidder), item.price, item.onAuction, item.onSale, item.endTime, item.highestBidder, item.highestBid, item.currency, item.isActive, item.stored);
    }

    /* Allows user to claim items */
    function claimItem(uint256 offerId, address claimer) onlyApprovals public {
        IStorageOA iStorage = IStorageOA(address_storage);
        IStorageOA.StorageItem memory item = iStorage.getItem(offers[offerId].itemId);
        require(offers[offerId].accepted, "The offer has not been accepted");
        require(claimer == item.owner, "Only the winner can claim the nft.");
        iStorage.transferItem(item.itemId, claimer);
    }

    /* Returns item's offers */
    function getOffersByItem (uint256 itemId) public view returns (Offer[] memory) {
        uint256 totalItemCount = _offerIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (offers[i + 1].itemId == itemId) {
                itemCount += 1;
            }
        }

        Offer[] memory items = new Offer[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (offers[i + 1].itemId == itemId) {
                uint256 currentId = i + 1;
                Offer storage currentItem = offers[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Return item's offers currently active */
    function getActiveOffersByItem (uint256 itemId) public view returns (Offer[] memory) {
        uint256 totalItemCount = _offerIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (offers[i + 1].itemId == itemId && block.timestamp < offers[i + 1].endTime) {
                itemCount += 1;
            }
        }

        Offer[] memory items = new Offer[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (offers[i + 1].itemId == itemId && block.timestamp < offers[i + 1].endTime) {
                uint256 currentId = i + 1;
                Offer storage currentItem = offers[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    /* Set storage address */
    function setStorageAddress (address _address_storage) onlyOwner public {
        address_storage = _address_storage;
    }
}
