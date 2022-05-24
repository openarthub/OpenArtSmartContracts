// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PreSale is ReentrancyGuard {
  IERC20 private erc20;
  uint256 public constant ENTRY_PRICE = 0.000002 ether;
  uint256 public constant MIN_PURCHASE = 100000;
  uint256 public constant MAX_PURCHASE = 10000000;
  uint256 public tokensBought = 0;
  address private owner;
  uint256 public endTime;
  uint256 public startTime;

  mapping(address => Beneficary) private owners;
  mapping(uint256 => uint256) public unlocksTime;

  constructor(address _tokenAddress, uint256 _startTime, uint256 _endTime) {
    erc20 = IERC20(_tokenAddress);
    startTime = _startTime;
    endTime = _endTime;

    unlocksTime[1] = 1653336000;
    unlocksTime[2] = 1653337000;
    unlocksTime[3] = 1653338000;
    unlocksTime[4] = 1653339000;
    unlocksTime[5] = 1653340000;
    unlocksTime[6] = 1653341000;
    unlocksTime[7] = 1653342000;
    unlocksTime[8] = 1653343000;
    unlocksTime[9] = 1653344000;
    unlocksTime[10] = 1653345000;
    unlocksTime[11] = 1653346000;
    unlocksTime[12] = 1653347000;
    unlocksTime[13] = 1653348000;
    unlocksTime[14] = 1653349000;
    unlocksTime[15] = 1653350000;
    unlocksTime[16] = 1653351000;
    unlocksTime[17] = 1653352000;
    unlocksTime[18] = 1653353000;
    unlocksTime[19] = 1653354000;
    unlocksTime[20] = 1653355000;
    unlocksTime[21] = 1653356000;
    unlocksTime[22] = 1653357000;
    unlocksTime[23] = 1653358000;
    unlocksTime[24] = 1653359000;

    owner = msg.sender;
  }

  struct Beneficary {
    uint256 unlocks;
    uint256 amount;
  }

  function claim() public nonReentrant {
    require(owners[msg.sender].unlocks < 24, "You already unlocked all your tokens");
    require(block.timestamp >= unlocksTime[(owners[msg.sender].unlocks + 1)], "Must have reached unlock time.");
    require(owners[msg.sender].amount > 0, "You do not have tokens to unlock");
    uint256 amountUnlock;
    if (owners[msg.sender].unlocks == 0) {
      amountUnlock = ((owners[msg.sender].amount * 5) / 100);
    }
    if (owners[msg.sender].unlocks > 0 && owners[msg.sender].unlocks < 23) {
      amountUnlock = ((owners[msg.sender].amount * 4) / 100);
    }
    if (owners[msg.sender].unlocks >= 23) {
      amountUnlock = ((owners[msg.sender].amount * 7) / 100);
    }
    require(erc20.transfer(msg.sender, (amountUnlock * 1 ether)), "An error ocuurred at make the transaction.");
    owners[msg.sender].unlocks += 1;
  }

  function buy(uint256 tokensQuantity) public payable {
    require(block.timestamp < endTime, "Pre-sale has ended.");
    require(block.timestamp >= startTime, "Pre-sale has not started yet.");
    require((owners[msg.sender].amount + tokensQuantity) <= MAX_PURCHASE, "Your purchase exceeds the maximum purchase");
    require(
      erc20.balanceOf(address(this)) >= (tokensQuantity + tokensBought),
      "There is not that quantity of tokens available to buy"
    );
    require(tokensQuantity >= MIN_PURCHASE, "The minimum amount to buy is 100,000 tokens");
    uint256 amountPayment = tokensQuantity * ENTRY_PRICE;
    require(msg.value == amountPayment, "The sent value not match with the amount to pay");
    owners[msg.sender].amount += tokensQuantity;
    tokensBought += tokensQuantity;
  }

  function getQuantityOfTokensAvailable() public view returns (uint256) {
    return (erc20.balanceOf(address(this)) / 1 ether) - tokensBought;
  }

  function beneficaryState(address beneficaryAddress) public view returns (Beneficary memory) {
    return owners[beneficaryAddress];
  }

  function amountToPay(uint256 value) public pure returns (uint256) {
    return value * ENTRY_PRICE;
  }

  function getRecover() public {
    require(msg.sender == owner, "Only contract's owner can execute this method.");
    uint256 balance = address(this).balance;
    payable(owner).transfer(balance);
  }

  function getUnlocksTime() public view returns (uint256 [] memory) {
    uint256[] memory unlocks = new uint256[](24);
    for (uint16 i = 1; i < 25; i++) {
      unlocks[i - 1] = unlocksTime[i];
    }

    return unlocks;
  }
}
