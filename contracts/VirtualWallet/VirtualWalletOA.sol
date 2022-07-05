// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../utils/ApprovalsGuard.sol";

/** @author OutDev Team */
/** @title Virtual Wallet */
contract VirtualWalletOA is ApprovalsGuard {
  mapping (address => uint256) private _balancesOART;
  mapping (address => uint256) private _balances;
  address private _tokenAddress;

  struct Balances {
    uint256 oartBalance;
    uint256 ethBalance;
  }

  /**
    * @dev Initializa de contract by setting the erc20 token address and an approval
    * @param tokenAddress Initial erc20 token address
    * @param approval Initial address aproved
  */
  constructor (address tokenAddress, address approval) {
    _tokenAddress = tokenAddress;
    setApproval(approval, true);
  }

  /**
    * @dev Moves amount of tokens to 'to' address and dicrease balance of 'from'
    * The call is not executed if addres sender is not registered in approvals
    * @param from The address for dicrease tokens balance
    * @param to The address to send tokens
    * @param amount The amount to send
  */
  function transferOART(address from, address to, uint256 amount) external onlyApprovals {
    require(_balancesOART[from] >= amount, "Transfer amount exceeds balance.");
    unchecked {
      _balancesOART[from] - amount;
    }
    require(IERC20(_tokenAddress).transfer(to, amount), "Error at transaction");
  }

  /**
    * @dev Transefer eht to 'to' address and dicrease balance of 'from'
    * The call is not executed if addres sender is not registered in approvals
    * @param from The address for dicrease eth balance
    * @param to The address to send eth
    * @param amount The amount to send
  */
  function transfer(address from, address to, uint256 amount) external onlyApprovals {
    require(_balances[from] >= amount, "Transfer amount exceeds balance.");
    unchecked {
      _balances[from] - amount;
    }
    payable(to).transfer(amount);
  }

  /**
    * @dev Take tokens from user's wallet to fund user's virtual wallet
    * @param amount Amount of tokens to fund
  */
  function fundOART (uint256 amount) external {
    require(IERC20(_tokenAddress).transferFrom(msg.sender, address(this), amount), "Error at get tokens");
    unchecked {
      _balancesOART[msg.sender] += amount;
    }
  }

  /**
    * @dev Get eth from user to fund user's virtual wallet
  */
  function fundAccount () external payable {
    _balances[msg.sender] += msg.value;
  }

  /**
   * @dev Get user's virtual balances
   * @param walletAddress address to get balances
   * @return Balances return a struct that contais user's OARTs and eth balances.
  */

  function getBalances(address walletAddress) external view returns (Balances memory) {
    return Balances(_balancesOART[walletAddress], _balances[walletAddress]);
  }

  /**
    * @dev Change erc20 token address
    * @param tokenAddress New token adress
  */
  function setTokenAddress(address tokenAddress) external onlyOwner {
    _tokenAddress = tokenAddress;
  }
}
