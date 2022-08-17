// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC721Royalties {
  function createToken(string memory tokenURI) external returns (uint256);

  function createToken(
    string memory tokenURI,
    uint256 royaltiesPercent,
    address royaltiesReceiver
  ) external returns (uint256);

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;
}
