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

  mapping(address => Beneficary) private owners;
  mapping(uint256 => uint256) public unlocksTime;

  constructor(address _tokenAddress, uint256 _endTime) {
    erc20 = IERC20(_tokenAddress);
    endTime = _endTime;

    unlocksTime[1] = 1650490225;
    unlocksTime[2] = 1650492025;
    unlocksTime[3] = 1650495625;
    unlocksTime[4] = 1650499225;
    unlocksTime[5] = 1650502825;
    unlocksTime[6] = 1650506425;
    unlocksTime[7] = 1650510025;
    unlocksTime[8] = 1650513625;
    unlocksTime[9] = 1650517225;
    unlocksTime[10] = 1650524425;
    unlocksTime[11] = 1650528025;
    unlocksTime[12] = 1650531625;
    unlocksTime[13] = 1650531635;
    unlocksTime[14] = 1650531645;
    unlocksTime[15] = 1650531655;
    unlocksTime[16] = 1650531665;
    unlocksTime[17] = 1650531705;
    unlocksTime[18] = 1650531725;
    unlocksTime[19] = 1650549625;
    unlocksTime[20] = 1650489925;
    unlocksTime[21] = 1650556825;
    unlocksTime[22] = 1650558625;
    unlocksTime[23] = 1650558925;
    unlocksTime[24] = 1650560425;

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
    require(block.timestamp < endTime, "Private pre-sale had ended.");
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
}
