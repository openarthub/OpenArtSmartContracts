// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PreSale {
  IERC20 private erc20;
  uint256 public ENTRY_PRICE = 0.000002 ether;
  uint256 public MIN_PURCHASE = 100000;
  uint256 public MAX_PURCHASE = 10000000;
  uint256 public tokens_bought = 0;
  address private owner;
  uint256 public end_time;

  mapping(address => Beneficary) private owners;
  mapping(uint256 => uint256) public unlocks_time;

  constructor(address _token_address, uint256 _end_time)
  {
    erc20 = IERC20(_token_address);
    end_time = _end_time;

    unlocks_time[1] = 1650490225;
    unlocks_time[2] = 1650492025;
    unlocks_time[3] = 1650495625;
    unlocks_time[4] = 1650499225;
    unlocks_time[5] = 1650502825;
    unlocks_time[6] = 1650506425;
    unlocks_time[7] = 1650510025;
    unlocks_time[8] = 1650513625;
    unlocks_time[9] = 1650517225;
    unlocks_time[10] = 1650524425;
    unlocks_time[11] = 1650528025;
    unlocks_time[12] = 1650531625;
    unlocks_time[13] = 1650531635;
    unlocks_time[14] = 1650531645;
    unlocks_time[15] = 1650531655;
    unlocks_time[16] = 1650531665;
    unlocks_time[17] = 1650531705;
    unlocks_time[18] = 1650531725;
    unlocks_time[19] = 1650549625;
    unlocks_time[20] = 1650489925;
    unlocks_time[21] = 1650556825;
    unlocks_time[22] = 1650558625;
    unlocks_time[23] = 1650558925;
    unlocks_time[24] = 1650560425;


    owner = msg.sender;

  }

  struct Beneficary {
    uint256 unlocks;
    uint256 amount;
  }
 
  function claim() public {
    require(owners[msg.sender].unlocks < 24, "You already unlocked all your tokens");
    require(block.timestamp >= unlocks_time[(owners[msg.sender].unlocks + 1)], "Must have reached unlock time.");
    require(owners[msg.sender].amount > 0, "You do not have tokens to unlock");
    uint amount_to_unlock;
    if (owners[msg.sender].unlocks == 0) {
      amount_to_unlock = (owners[msg.sender].amount * 5 / 100);
    }
    if (owners[msg.sender].unlocks > 0 && owners[msg.sender].unlocks < 23) {
      amount_to_unlock = (owners[msg.sender].amount * 4 / 100);
    }
    if (owners[msg.sender].unlocks >= 23) {
      amount_to_unlock = (owners[msg.sender].amount * 7 / 100);
    } 
    require(erc20.transfer(msg.sender, (amount_to_unlock * 1 ether)), "An error ocuurred at make the transaction.");
    owners[msg.sender].unlocks += 1;
  }

  function buy(uint tokens_quantity) public payable
  {
    require(block.timestamp < end_time, "Private pre-sale had ended.");
    require((owners[msg.sender].amount + tokens_quantity) <= MAX_PURCHASE, "Your purchase exceeds the maximum purchase");
    require(erc20.balanceOf(address(this)) >= (tokens_quantity + tokens_bought), "There is not that quantity of tokens available to buy");
    require(tokens_quantity >= MIN_PURCHASE, "The minimum amount to buy is 100,000 tokens");
    uint amount_payment = tokens_quantity * ENTRY_PRICE;
    require(msg.value == amount_payment, "The sent value not match with the amount to pay");
    owners[msg.sender].amount += tokens_quantity;
    tokens_bought += tokens_quantity;
  }

  function getQuantityOfTokensAvailable() view public returns (uint256) {
    return (erc20.balanceOf(address(this)) / 1 ether ) - tokens_bought;
  }

  function beneficaryState() view public returns (Beneficary memory) {
    return owners[msg.sender];
  }

  function amountToPay(uint value) view public returns (uint256) {
    return value * ENTRY_PRICE;
  }

  function getRecover () public {
    require(msg.sender == owner, "Only contract's owner can execute this method.");
    uint256 balance = address(this).balance;
    payable(owner).transfer(balance);
  }
}