// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../StorageOA/IStorageOA.sol";
import "../../utils/ApprovalsGuard.sol";

contract SalesOA is ReentrancyGuard, ApprovalsGuard  {

    address address_storage;
    uint256 listingPrice;

    constructor(uint256 _listingPrice, address _address_storage) {
        listingPrice = _listingPrice;
        address_storage = _address_storage;
    }

    /* Returns the listing price of the contract */
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(uint256 itemId, address buyer) onlyApprovals public payable nonReentrant {
        IStorageOA iStorage = IStorageOA(address_storage);
        IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
        require(item.onSale, "This Item is not on sale.");
        require(item.owner != buyer, "You are the owner of this nft");
        require(item.currency != address(0) || msg.value == item.price, "The value sent must be equals to nft's price");

        uint256 price = item.price;

        if (item.currency != address(0)) {
            IERC20 erc20 = IERC20(item.currency);
            require(
                erc20.transferFrom(buyer, address(this), price) &&
                erc20.transfer(item.owner, (price - (price * listingPrice / 100))) &&
                erc20.transfer(owner, (price * listingPrice / 100))
            , "Transaction failed at pay item");
        } else {
            payable(item.owner).transfer((price - (price * listingPrice / 100)));
            payable(owner).transfer((price * listingPrice / 100));
        }

        iStorage.transferItem(itemId, buyer);
    }

    /* Change listing price in hundredths*/
    function setListingPrice (uint percent) onlyOwner public {
        listingPrice = percent;
    }

    /* Put on sale */
    function activateSale(uint256 itemId, uint256 price, address currency, address seller) onlyApprovals public {
        IStorageOA iStorage = IStorageOA(address_storage);
        IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
        require(seller == item.owner, "You are not owner of this nft");
        require(!item.onSale, "This item is on sale already");
        require(!item.onAuction, "This item is currently on auction");        
        IERC721(item.nftContract).transferFrom(item.owner, address_storage, item.tokenId);
        iStorage.setItem(itemId, payable(seller), price, false, true, 0, address(0), 0, currency, true, address_storage);
    }

    /* Remove from sale */
    function deactivateSale(uint256 itemId, address seller) onlyApprovals public {
        IStorageOA iStorage = IStorageOA(address_storage);
        IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
        require(seller == item.owner, "You are not owner of this nft");
        iStorage.transferItem(itemId, seller);
    }

    /* Set storage address */
    function setStorageAddress (address _address_storage) onlyOwner public {
        address_storage = _address_storage;
    }
}
