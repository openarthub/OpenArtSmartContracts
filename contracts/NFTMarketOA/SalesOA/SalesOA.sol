// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../StorageOA/IStorageOA.sol";
import "../../utils/ApprovalsGuard.sol";
import "../Events/IEvents.sol";

import "hardhat/console.sol";

contract SalesOA is ReentrancyGuard, ApprovalsGuard, IEvents {
  address private _addressStorage;
  uint256 private _listingPrice;

  constructor(uint256 listingPrice, address addressStorage) {
    _listingPrice = listingPrice;
    _addressStorage = addressStorage;
  }

  /* Returns the listing price of the contract */
  function getListingPrice() public view returns (uint256) {
    return _listingPrice;
  }

  /* Transfers ownership of the item, as well as funds between parties */
  function createMarketSale(uint256 itemId, address buyer) external payable onlyApprovals nonReentrant {
    console.log("im inside");
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
    console.log("I got item from storage");
    console.log(item.owner);
    require(item.onSale, "This Item is not on sale.");
    require(item.owner != buyer, "You are the owner of this nft");
    require(item.currency != address(0) || msg.value == item.price, "The value sent must be equals to nft's price");

    uint256 price = item.price;

    if (item.currency != address(0)) {
      IERC20 erc20 = IERC20(item.currency);
      require(
        erc20.transferFrom(buyer, address(this), price) &&
          erc20.transfer(item.owner, (price - ((price * _listingPrice) / 100))) &&
          erc20.transfer(owner, ((price * _listingPrice) / 100)),
        "Transaction failed at pay item"
      );
    } else {
      console.log("Im gonna make payments");
      payable(item.owner).transfer((price - ((price * _listingPrice) / 100)));
      console.log("Im gonna make the second payment");
      payable(owner).transfer(((price * _listingPrice) / 100));
    }
    console.log("im gonna transfer item");
    iStorage.transferItem(itemId, buyer);
    console.log("item was transfered");
    emit SaleItem(item.owner, buyer, itemId, item.nftContract, item.tokenId, price, block.timestamp);
  }

  /* Change listing price in hundredths*/
  function setListingPrice(uint256 percent) public onlyOwner {
    _listingPrice = percent;
  }

  /* Put on sale */
  function activateSale(
    uint256 itemId,
    uint256 price,
    address currency,
    address seller
  ) external onlyApprovals {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
    require(seller == item.owner, "You are not owner of this nft");
    require(!item.onSale, "This item is on sale already");
    require(!item.onAuction, "This item is currently on auction");
    IERC721(item.nftContract).transferFrom(item.owner, _addressStorage, item.tokenId);
    iStorage.setItem(itemId, payable(seller), price, false, true, 0, address(0), 0, currency, true, _addressStorage);
    emit ListItem(seller, address(0), itemId, item.nftContract, item.tokenId, price, block.timestamp);
  }

  /* Remove from sale */
  function deactivateSale(uint256 itemId, address seller) public onlyApprovals {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
    require(seller == item.owner, "You are not owner of this nft");
    iStorage.transferItem(itemId, seller);
    emit Cancel(seller, address(0), itemId, item.nftContract, item.tokenId, block.timestamp);
  }

  /* Set storage address */
  function setStorageAddress(address addressStorage) public onlyOwner {
    _addressStorage = addressStorage;
  }
}
