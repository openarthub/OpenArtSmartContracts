// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface IEvents {
  event MakeOffer(
    address indexed from,
    address indexed to,
    uint256 indexed itemId,
    address nftContract,
    uint256 tokenId,
    uint256 amount,
    uint256 endTime,
    uint256 date
  );

  event ListItem(
    address indexed from,
    address indexed to,
    uint256 indexed itemId,
    address nftContract,
    uint256 tokenId,
    uint256 amount,
    uint256 date
  );

  event SaleItem(
    address indexed from,
    address indexed to,
    uint256 indexed itemId,
    address nftContract,
    uint256 tokenId,
    uint256 amount,
    uint256 date
  );

  event Cancel(
    address indexed from,
    address indexed to,
    uint256 indexed itemId,
    address nftContract,
    uint256 tokenId,
    uint256 date
  );
}