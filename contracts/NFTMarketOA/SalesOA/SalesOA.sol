// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../../ERC721OA/IERC721OA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../StorageOA/IStorageOA.sol";
import "../../utils/ApprovalsGuard.sol";
import "../Events/IEvents.sol";

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
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);
    require(item.onSale, "This Item is not on sale.");
    require(item.owner != buyer, "You are the owner of this nft");
    require(item.currency != address(0) || msg.value == item.price, "The value sent must be equals to nft's price");

    uint256 price = item.price;

    address royaltiesReceiver;
    uint256 royaltiesAmount;

    if (item.firstSold) {
      try IERC721OA(item.nftContract).royaltyInfo(item.itemId, item.price) returns (
        address receiver,
        uint256 royaltyAmount
      ) {
        royaltiesReceiver = receiver;
        royaltiesAmount = royaltyAmount;
      } catch {}
    }

    if (item.currency != address(0)) {
      IERC20 erc20 = IERC20(item.currency);

      require(erc20.transferFrom(buyer, address(this), price), "Transaction failed at pay item.");
      if (royaltiesAmount > 0) {
        require(erc20.transfer(royaltiesReceiver, royaltiesAmount), "Transaction failed");
      }
      require(
        erc20.transfer(item.owner, (price - ((price * _listingPrice) / 100) - royaltiesAmount)) &&
          erc20.transfer(owner, ((price * _listingPrice) / 100)),
        "Transaction failed at pay item"
      );
    } else {
      if (royaltiesAmount > 0) {
        payable(royaltiesReceiver).transfer(royaltiesAmount);
      }
      payable(item.owner).transfer((price - ((price * _listingPrice) / 100) - royaltiesAmount));
      payable(owner).transfer(((price * _listingPrice) / 100));
    }
    emit SaleItem(item.owner, buyer, itemId, item.nftContract, item.tokenId, price, block.timestamp);
    iStorage.transferItem(itemId, buyer);
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
    item.owner = payable(seller);
    item.price = price;
    item.onSale = true;
    item.endTime = 0;
    item.currency = currency;
    item.stored = _addressStorage;
    iStorage.setItem(itemId, item);
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
