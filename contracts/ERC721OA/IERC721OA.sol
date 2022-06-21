// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721OA is IERC721 {
  function createToken(string memory tokenURI) external returns (uint256);
}
