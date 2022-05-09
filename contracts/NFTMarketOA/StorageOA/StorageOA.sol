// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../NFTMarketOA/INFTMarketOA.sol";

contract StorageOA {
    // Mapping of approved address to write storage
    mapping(address => bool) private _approvals;

    // Modifier to allow only approvals to execute methods
    modifier onlyApprovals {
        require(_approvals[msg.sender], "You are not allowed to execute this method");
        _;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    address payable owner;

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
        uint highestBid;
        address currency;
        bool isActive;
        address stored;
    }

    mapping(uint256 => StorageItem) private storedItems;

    constructor(address address_backup) {
        owner = payable(msg.sender);
        INFTMarketOA.MarketItem[] memory oldData = INFTMarketOA(address_backup).fetchMarketItems();

        for (uint256 item = 0; item < oldData.length; item++) {
            _itemIds.increment();
            uint256 itemId = _itemIds.current();
            storedItems[itemId] = StorageItem(
                itemId, oldData[item].nftContract, oldData[item].tokenId,
                payable(oldData[item].owner), oldData[item].price,
                oldData[item].onAuction, oldData[item].onSale,
                oldData[item].endTime, oldData[item].highestBidder,
                oldData[item].highestBid, oldData[item].currency,
                oldData[item].isActive,
                address(0)
            );
        }
    }

    event ItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address owner,
        bool onAuction,
        bool onSale
    );

    // Method to get all actives items
    function getItems() public view returns (StorageItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (storedItems[i + 1].isActive) {
                itemCount += 1;
            }
        }

        StorageItem[] memory items = new StorageItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (storedItems[i + 1].isActive) {
                uint256 currentId = i + 1;
                StorageItem storage currentItem = storedItems[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // Method to get actives items by collection
    function getItemsByCollection(address collectionAddress) public view returns (StorageItem[] memory) {
        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

       for (uint256 i = 0; i < totalItemCount; i++) {
            if (storedItems[i + 1].nftContract == collectionAddress && storedItems[i + 1].isActive) {
                itemCount += 1;
            }
        }

        StorageItem[] memory items = new StorageItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (storedItems[i + 1].nftContract == collectionAddress && storedItems[i + 1].isActive) {
                uint256 currentId = i + 1;
                StorageItem storage currentItem = storedItems[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // Method to get items by owner
    function getItemsByOwner(address address_owner) public view returns (StorageItem[] memory) {

        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (storedItems[i + 1].owner == address_owner) {
                itemCount += 1;
            }
        }

        StorageItem[] memory items = new StorageItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (storedItems[i + 1].owner == address_owner) {
                uint256 currentId = i + 1;
                StorageItem storage currentItem = storedItems[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    // Method to get disabled items by owner
    function getDisabledItemsByOwner (address address_owner) onlyApprovals public view returns (StorageItem[] memory) {

        uint256 totalItemCount = _itemIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        for (uint256 i = 0; i < totalItemCount; i++) {
            if (storedItems[i + 1].owner == address_owner &&  !storedItems[i + 1].isActive) {
                itemCount += 1;
            }
        }

        StorageItem[] memory items = new StorageItem[](itemCount);
        for (uint256 i = 0; i < totalItemCount; i++) {
            if (storedItems[i + 1].owner == address_owner && !storedItems[i + 1].isActive) {
                uint256 currentId = i + 1;
                StorageItem storage currentItem = storedItems[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function getItem (uint256 itemId) public view returns (StorageItem memory) {
        return storedItems[itemId];
    }

    function approvalForTransfer(address addressContract, bool approved) public {
        require(msg.sender == owner, "You are not allowed to execute this function");
        _approvals[addressContract] = approved;
    }

    /* Allows other contract to send this contract's nft */
    function transferNFT(address nftContract, address to, uint256 nftId) onlyApprovals public {
        IERC721(nftContract).transferFrom(address(this), to, nftId);
    }

    function setItem(uint256 itemId, address payable owner_item, uint256 price, bool onAuction, bool onSale, bool isActive, address stored) onlyApprovals public {
        storedItems[itemId].owner = owner_item;
        storedItems[itemId].price = price;
        storedItems[itemId].onAuction = onAuction;
        storedItems[itemId].onSale = onSale;
        storedItems[itemId].isActive = isActive;
        storedItems[itemId].stored = stored;
    }

    function createItem(address nftContract, uint256 tokenId, bool isActive, address owner_item) onlyApprovals public {
        require(IERC721(nftContract).ownerOf(tokenId) == owner_item, "You are not owner of this nft.");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        storedItems[itemId] = StorageItem(
            itemId, nftContract, tokenId, payable(owner_item), 0, false, false, 0, address(0), 0, address(0), isActive, address(0)
        );

        emit ItemCreated(
            itemId, nftContract, tokenId, owner_item, false, false
        );
    }

}
