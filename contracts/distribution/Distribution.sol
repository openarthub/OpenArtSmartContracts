// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @author OutDev Team
 * @title Distribution
 * @notice Contract that distribute initial earns in agreed slices.
 */
contract Distribution is Ownable {
  address private PROMOTER;
  address private OPENART;
  address private CREATOR;

  bytes public constant AGREEMENT = "Message of the contract";

  uint256 private PERCENT_PROMOTER = 0;
  uint256 private PERCENT_OPENART = 50;
  uint256 private PERCENT_CREATOR = 50;

  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  address[] private _tokens = new address[](3);

  // address account -> address token -> balance of address account
  mapping(address => mapping(address => uint256)) private _amountReceived;

  struct Balance {
    address token;
    uint256 amount;
  }

  /**
   * @notice Initialize contract with the partners addresses and tokens
   * @custom:detail Add address 0 to allow native currency
   */
  constructor(
    address openartAddress_,
    address promoterAddress_,
    address creatorAddress_,
    address[] memory tokens_
  ) {
    _status = _NOT_ENTERED;
    PROMOTER = promoterAddress_;
    OPENART = openartAddress_;
    CREATOR = creatorAddress_;
    _tokens = tokens_;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   */
  modifier nonReentrant() {
    _nonReentrantBefore();
    _;
    _nonReentrantAfter();
  }

  /**
   * @dev Set state of reentrancy state to True
   * @custom:restriction Cannot be accessed if reentrancy
   *  state is True already
   */
  function _nonReentrantBefore() private {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
  }

  /**
   * @notice Set address receiver of PROMOTER earns.
   * @param wallet Address that will be set as receiver.
   * @custom:restriction Only owner can execute this function.
   */
  function setPromoterAddress(address wallet) external onlyOwner {
    PROMOTER = wallet;
  }

  /**
   * @notice Set address receiver of CREATOR earns.
   * @param wallet Address that will be set as receiver.
   * @custom:restriction Only owner can execute this function.
   */
  function setCreatorAddress(address wallet) external onlyOwner {
    CREATOR = wallet;
  }

  /**
   * @notice Set address receiver of OPENART earns.
   * @param wallet Address that will be set as receiver.
   * @custom:restriction Only owner can execute this function.
   */
  function setOpenArtAddress(address wallet) external onlyOwner {
    OPENART = wallet;
  }

  /**
   * @notice Set distribution percent of each member.
   * The sum of percents must be equals to 100.
   * @param percentPromoter Percent of earns for PROMOTER.
   * @param percentCreator Percent of earns for CREATOR.
   * @param percentOpenArt Percent of earns for OPENART.
   * @custom:restriction Only owner can execute this function.
   */
  function setDistributionPercents(
    uint256 percentPromoter,
    uint256 percentCreator,
    uint256 percentOpenArt
  ) external onlyOwner {
    require((percentPromoter + percentCreator + percentOpenArt) == 100, "DISTRIBUTION: The total percent must be 100.");
    PERCENT_PROMOTER = percentPromoter;
    PERCENT_OPENART = percentOpenArt;
    PERCENT_CREATOR = percentCreator;
  }

  /**
   * @dev Set state of reentrancy state to False
   */
  function _nonReentrantAfter() private {
    _status = _NOT_ENTERED;
  }

  /**
   * @dev Prevent a contract from be called for no members
   */
  modifier onlyMembers() {
    require(
      msg.sender == PROMOTER || msg.sender == OPENART || msg.sender == CREATOR,
      "You are not allowed to execute this method"
    );
    _;
  }

  /**
   * @dev Get caller's balance in the contract.
   * @param sender address of user
   * @custom:restriction Cannot be accessed if caller is not member.
   * @return balances returns caller's tokens and ether available.
   */
  function balance(address sender) external view returns (Balance[] memory) {
    Balance[] memory balances = new Balance[](_tokens.length);
    uint256 percent;
    if (sender == PROMOTER) {
      percent = PERCENT_PROMOTER;
    }

    if (sender == OPENART) {
      percent = PERCENT_OPENART;
    }

    if (sender == CREATOR) {
      percent = PERCENT_CREATOR;
    }

    for (uint256 i; i < _tokens.length; ) {
      if (_tokens[i] == address(0)) {
        balances[i] = (Balance(_tokens[i], ((address(this).balance * percent) / 100)));
      } else {
        balances[i] = (Balance(_tokens[i], ((IERC20(_tokens[i]).balanceOf(address(this)) * percent) / 100)));
      }
      unchecked {
        ++i;
      }
    }

    return balances;
  }

  /**
   * @dev Transfer caller's available balance.
   * @param currencies Addresses of the tokens to collect.
   * @custom:detail The address zero is used as the address of the native currency.
   * @custom:restriction Cannot be accessed if caller is not member.
   */
  function getProfits(address[] memory currencies) external onlyMembers nonReentrant {
    uint256 amount1;
    uint256 amount2;
    uint256 amount3;
    require(currencies.length <= _tokens.length, "Tokens addresses exceeds tokens amount.");
    for (uint256 i; i < currencies.length; ) {
      if (currencies[i] == address(0)) {
        amount1 = (address(this).balance * PERCENT_PROMOTER) / 100;
        amount2 = (address(this).balance * PERCENT_OPENART) / 100;
        amount3 = (address(this).balance * PERCENT_CREATOR) / 100;
      } else {
        amount1 = (IERC20(currencies[i]).balanceOf(address(this)) * PERCENT_PROMOTER) / 100;
        amount2 = (IERC20(currencies[i]).balanceOf(address(this)) * PERCENT_OPENART) / 100;
        amount3 = (IERC20(currencies[i]).balanceOf(address(this)) * PERCENT_CREATOR) / 100;
      }

      _transfer(currencies[i], PROMOTER, amount1);
      _transfer(currencies[i], OPENART, amount2);
      _transfer(currencies[i], CREATOR, amount3);

      unchecked {
        ++i;
      }
    }
  }

  /**
   * @notice Retrieve addresses of tokens supported by the contract.
   * @return address[] Array of addresses of tokens supported.
   */
  function getTokensEnabled() external view returns (address[] memory) {
    return _tokens;
  }

  /**
   * @notice Add a new token for the contract.
   *  Percents for the new token are equals.
   * @param token Address of token to add.
   * @custom:restriction It can be executed only by the owner.
   */
  function setToken(address token) external onlyOwner {
    _tokens.push(token);
  }

  /**
   * @notice Delete token from contract.
   * @param token Address of token to remove.
   * @custom:restriction It can be executed only by the owner.
   */
  function removeToken(address token) external onlyOwner {
    for (uint256 i; i < _tokens.length; ) {
      if (_tokens[i] == token) {
        _tokens[i] = _tokens[_tokens.length - 1];
        _tokens.pop();
        break;
      }
      unchecked {
        ++i;
      }
    }
  }

  function _transfer(
    address token_,
    address to_,
    uint256 amount_
  ) internal returns (bool status) {
    if (amount_ <= 0) return status;
    _amountReceived[to_][token_] += amount_;
    if (token_ != address(0)) {
      IERC20(token_).transfer(to_, amount_);
      return true;
    }

    (status, ) = payable(to_).call{value: amount_}("");
    require(status, "Distribution: Error at transfer");
  }

  /**
   * @notice Get the amount of tokens that an user has earned.
   * @param account Address of user to get received amount.
   * @param tokens_ Array of tokens' addresses to get.
   * @custom:detail Address zero is uses as native currency address.
   * @return Balance Array of structs that contain address of the token and amount received.
   */
  function getReceived(address account, address[] memory tokens_) external view returns (Balance[] memory) {
    Balance[] memory balances = new Balance[](tokens_.length);
    for (uint256 i; i < tokens_.length; ) {
      balances[i] = Balance(tokens_[i], _amountReceived[account][tokens_[i]]);
      unchecked {
        ++i;
      }
    }
    return balances;
  }

  receive() external payable {}

  fallback() external payable {}
}
