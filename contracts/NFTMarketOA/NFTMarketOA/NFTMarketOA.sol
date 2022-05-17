// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTMarketOA is ReentrancyGuard {
  // Mapping of approved address to send contract's nfts
  mapping(address => bool) private _approvals;

  using Counters for Counters.Counter;
  Counters.Counter private _itemIds;
  Counters.Counter private _itemsSold;

  address payable owner;
  uint256 listingPrice;

  constructor(uint256 _listingPrice, address address_backup) payable {
    owner = payable(msg.sender);
    listingPrice = _listingPrice;
    if (address_backup == address(0)) return;
    MarketItem[] memory oldData = NFTMarketOA(address_backup).fetchMarketItems();

    for (uint256 item = 0; item < oldData.length; item++) {
      _itemIds.increment();
      uint256 itemId = _itemIds.current();
      marketItems[itemId] = MarketItem(
        itemId,
        oldData[item].nftContract,
        oldData[item].tokenId,
        payable(oldData[item].owner),
        oldData[item].price,
        oldData[item].sold,
        oldData[item].onAuction,
        oldData[item].onSale,
        oldData[item].endTime,
        oldData[item].highestBidder,
        oldData[item].highestBid,
        oldData[item].currency,
        oldData[item].isActive
      );
    }
  }

  struct MarketItem {
    uint256 itemId;
    address nftContract;
    uint256 tokenId;
    address payable owner;
    uint256 price;
    bool sold;
    bool onAuction;
    bool onSale;
    uint256 endTime;
    address highestBidder;
    uint256 highestBid;
    address currency;
    bool isActive;
  }

  mapping(uint256 => MarketItem) private marketItems;

  event MarketItemCreated(
    uint256 indexed itemId,
    address indexed nftContract,
    uint256 indexed tokenId,
    address owner,
    uint256 price,
    bool sold,
    bool onAuction,
    bool onSale,
    uint256 endTime,
    address highestBidder,
    uint256 highestBid
  );

  function myallowance(address currency) public view returns (uint256) {
    IERC20 erc20 = IERC20(currency);
    return erc20.allowance(msg.sender, address(this));
  }

  /* Returns the listing price of the contract */
  function getListingPrice() public view returns (uint256) {
    return listingPrice;
  }

  /* Places an item for sale on the marketplace */
  function createMarketItem(
    address nftContract,
    uint256 tokenId,
    bool isActive
  ) public {
    require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "You are not owner of this nft.");

    _itemIds.increment();
    uint256 itemId = _itemIds.current();
    marketItems[itemId] = MarketItem(
      itemId,
      nftContract,
      tokenId,
      payable(msg.sender),
      0,
      false,
      false,
      false,
      0,
      address(0),
      0,
      address(0),
      isActive
    );

    emit MarketItemCreated(itemId, nftContract, tokenId, msg.sender, 0, false, false, false, 0, address(0), 0);
  }

  /* Creates the sale of a marketplace item */
  /* Transfers ownership of the item, as well as funds between parties */
  function createMarketSale(address nftContract, uint256 itemId) public payable nonReentrant {
    require(marketItems[itemId].onSale, "This Item is not on sale.");

    require(marketItems[itemId].owner != msg.sender, "You are the owner of this nft");

    require(
      marketItems[itemId].currency != address(0) || msg.value == marketItems[itemId].price,
      "The value sent must be equals to nft's price"
    );

    uint256 price = marketItems[itemId].price;
    uint256 tokenId = marketItems[itemId].tokenId;

    if (marketItems[itemId].currency != address(0)) {
      IERC20 erc20 = IERC20(marketItems[itemId].currency);
      require(
        erc20.transferFrom(msg.sender, address(this), price) &&
          erc20.transfer(marketItems[itemId].owner, (price - ((price * listingPrice) / 100))) &&
          erc20.transfer(owner, ((price * listingPrice) / 100)),
        "Transaction failed at pay item"
      );
    } else {
      payable(marketItems[itemId].owner).transfer((price - ((price * listingPrice) / 100)));
      payable(owner).transfer(((price * listingPrice) / 100));
    }

    IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
    marketItems[itemId].owner = payable(msg.sender);
    marketItems[itemId].sold = true;
    marketItems[itemId].onSale = false;
    _itemsSold.increment();
  }

  /* Returns all unsold market items */
  function fetchMarketItems() public view returns (MarketItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (marketItems[i + 1].isActive) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (marketItems[i + 1].isActive) {
        uint256 currentId = i + 1;
        MarketItem storage currentItem = marketItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  function fetchCollectionItems(address collectionAddress) public view returns (MarketItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (marketItems[i + 1].nftContract == collectionAddress && marketItems[i + 1].isActive) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (marketItems[i + 1].nftContract == collectionAddress && marketItems[i + 1].isActive) {
        uint256 currentId = i + 1;
        MarketItem storage currentItem = marketItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns onlyl items that a user has purchased */
  function fetchMyNFTs() public view returns (MarketItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (marketItems[i + 1].owner == msg.sender) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (marketItems[i + 1].owner == msg.sender) {
        uint256 currentId = i + 1;
        MarketItem storage currentItem = marketItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns only disabled items that user owns */
  function fetchMyDisabledNFTs() public view returns (MarketItem[] memory) {
    uint256 totalItemCount = _itemIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (marketItems[i + 1].owner == msg.sender && !marketItems[i + 1].isActive) {
        itemCount += 1;
      }
    }

    MarketItem[] memory items = new MarketItem[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (marketItems[i + 1].owner == msg.sender && !marketItems[i + 1].isActive) {
        uint256 currentId = i + 1;
        MarketItem storage currentItem = marketItems[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Returns an element by its ID */

  function getItem(uint256 itemId) public view returns (MarketItem memory) {
    return marketItems[itemId];
  }

  /* Change listing price in hundredths*/
  function setListingPrice(uint256 percent) public {
    require(msg.sender == owner, "You are not allowed to execute this function");
    listingPrice = percent;
  }

  /* Put on sale */
  function activateSale(
    uint256 itemId,
    uint256 price,
    address currency
  ) public {
    require(msg.sender == marketItems[itemId].owner, "You are not owner of this nft");
    require(!marketItems[itemId].onSale, "This item is on sale already");
    require(!marketItems[itemId].onAuction, "This item is currently on auction");
    IERC721(marketItems[itemId].nftContract).transferFrom(
      marketItems[itemId].owner,
      address(this),
      marketItems[itemId].tokenId
    );
    marketItems[itemId].onSale = true;
    marketItems[itemId].onAuction = false;
    marketItems[itemId].sold = false;
    marketItems[itemId].price = price;
    marketItems[itemId].currency = currency;
  }

  /* Remove from sale */
  function deactivateSale(uint256 itemId) public {
    require(msg.sender == marketItems[itemId].owner, "You are not owner of this nft");
    IERC721(marketItems[itemId].nftContract).transferFrom(
      address(this),
      marketItems[itemId].owner,
      marketItems[itemId].tokenId
    );
    marketItems[itemId].onSale = false;
    marketItems[itemId].onAuction = false;
  }

  /* put up for auction */
  function activateAuction(
    uint256 itemId,
    uint256 endTime,
    uint256 minBid,
    address currency
  ) public {
    require(msg.sender == marketItems[itemId].owner, "You are not owner of this nft");
    IERC721(marketItems[itemId].nftContract).transferFrom(
      marketItems[itemId].owner,
      address(this),
      marketItems[itemId].tokenId
    );
    marketItems[itemId].onSale = false;
    marketItems[itemId].onAuction = true;
    marketItems[itemId].sold = false;
    marketItems[itemId].endTime = endTime;
    marketItems[itemId].price = minBid;
    marketItems[itemId].currency = currency;
    marketItems[itemId].highestBidder = marketItems[itemId].owner;
    marketItems[itemId].highestBid = 0;
  }

  /* Allow users to bid */
  function bid(uint256 itemId, uint256 bidAmount) public {
    require(block.timestamp < marketItems[itemId].endTime, "The auction has already ended");
    require(marketItems[itemId].owner != msg.sender, "You are the owner of this nft");

    require(
      (bidAmount > marketItems[itemId].highestBid) ||
        (bidAmount == marketItems[itemId].price && marketItems[itemId].highestBid == 0),
      "There is already a higher or equal bid"
    );

    IERC20 erc20 = IERC20(marketItems[itemId].currency);
    require(erc20.transferFrom(msg.sender, address(this), bidAmount), "Transaction failed at get bid"); // Hold OARTs

    // Withdraw outbided auction
    if (marketItems[itemId].highestBidder != address(0)) {
      require(erc20.transfer(marketItems[itemId].highestBidder, marketItems[itemId].highestBid), "Transfer failed");
    }

    // Set new bid for current item
    marketItems[itemId].highestBidder = msg.sender;
    marketItems[itemId].highestBid = bidAmount;
  }

  /* Ends auction when time is done and sends the funds to the beneficiary */
  function auctionEnd(uint256 itemId) public {
    if (block.timestamp < marketItems[itemId].endTime) {
      revert("The auction has not ended yet");
    }

    if (!marketItems[itemId].onAuction) {
      revert("The function auctionEnd has already been called");
    }

    IERC20 erc20 = IERC20(marketItems[itemId].currency);

    marketItems[itemId].onAuction = false;
    if (marketItems[itemId].owner == owner) {
      require(erc20.transfer(owner, marketItems[itemId].highestBid), "Transfer failed");
    } else {
      require(
        erc20.transfer(
          marketItems[itemId].owner,
          (marketItems[itemId].highestBid - ((marketItems[itemId].highestBid * listingPrice) / 100))
        ),
        "Transfer to owner failed"
      );
      require(erc20.transfer(owner, ((marketItems[itemId].highestBid * listingPrice) / 100)), "Transfer failed");
    }
  }

  /* Allows user to transfer the earned NFT */
  function collectNFT(address nftContract, uint256 itemId) public {
    require(msg.sender == marketItems[itemId].highestBidder, "Only the winner can claim the nft.");
    IERC721(nftContract).transferFrom(address(this), marketItems[itemId].highestBidder, marketItems[itemId].tokenId);
    marketItems[itemId].owner = payable(marketItems[itemId].highestBidder);
    marketItems[itemId].sold = true;
    marketItems[itemId].onAuction = false;
    marketItems[itemId].highestBidder = address(0);
    marketItems[itemId].highestBid = 0;
    _itemsSold.increment();
  }

  /* Save address to allow it to access contract's nfts */
  function approvalForTransfer(address addressContract, bool approved) public {
    require(msg.sender == owner, "You are not allowed to execute this function");
    _approvals[addressContract] = approved;
  }

  /* Allows other contract to send this contract's nft */
  function transferNFT(
    address nftContract,
    address to,
    uint256 nftId
  ) public {
    require(_approvals[msg.sender], "You are not allowed to execute this function");
    IERC721(nftContract).transferFrom(address(this), to, nftId);
  }

  function setActiveItem(uint256 itemId, bool isActive) public {
    require(
      msg.sender == owner || msg.sender == marketItems[itemId].owner,
      "You are not allowed to modify this element"
    );
    marketItems[itemId].isActive = isActive;
  }
}
