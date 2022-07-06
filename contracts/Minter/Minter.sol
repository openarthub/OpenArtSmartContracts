// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "../utils/ApprovalsGuard.sol";
import "../ERC721OA/IERC721OA.sol";
import "../NFTMarketOA/StorageOA/IStorageOATrusted.sol";

contract Minter is ApprovalsGuard {
  address private _minterWallet;
  address private _storage;
  address private _adminWallet;

  constructor(
    address minterWallet,
    address storageAddress,
    address adminWallet
  ) {
    _minterWallet = minterWallet;
    _storage = storageAddress;
    _adminWallet = adminWallet;
    setApproval(minterWallet, true);
  }

  function mint(
    address contractAddress,
    string memory urlAsset,
    bool onSale,
    bool onAuction,
    bool isActive,
    uint256 endTime,
    address currency,
    uint256 price,
    address highestBidder,
    uint256 highestBid
  ) external onlyApprovals {
    console.log("address", contractAddress);
    IERC721OA erc721 = IERC721OA(contractAddress);
    uint256 tokenId = erc721.createToken(urlAsset);
    IStorageOA(_storage).trustedCreateItem(
      contractAddress,
      tokenId,
      isActive,
      _adminWallet,
      onSale,
      onAuction,
      endTime,
      currency,
      price,
      highestBidder,
      highestBid
    );
    erc721.transferFrom(address(this), _storage, tokenId);
  }

  /* Events from external contracts */
  event ItemCreated(uint256 indexed itemId, address indexed nftContract, uint256 indexed tokenId, address owner);
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
}
