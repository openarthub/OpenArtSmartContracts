// SPDX-License-Identifier: MIT
// Sources flattened with hardhat v2.9.6 https://hardhat.org

// File @openzeppelin/contracts/utils/Counters.sol@v4.6.0

// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
  struct Counter {
    // This variable should never be directly accessed by users of the library: interactions must be restricted to
    // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
    // this feature: see https://github.com/ethereum/solidity/issues/4637
    uint256 _value; // default: 0
  }

  function current(Counter storage counter) internal view returns (uint256) {
    return counter._value;
  }

  function increment(Counter storage counter) internal {
    unchecked {
      counter._value += 1;
    }
  }

  function decrement(Counter storage counter) internal {
    uint256 value = counter._value;
    require(value > 0, "Counter: decrement overflow");
    unchecked {
      counter._value = value - 1;
    }
  }

  function reset(Counter storage counter) internal {
    counter._value = 0;
  }
}

// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.6.0

// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
  /**
   * @dev Returns true if this contract implements the interface defined by
   * `interfaceId`. See the corresponding
   * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
   * to learn more about how these ids are created.
   *
   * This function call must use less than 30 000 gas.
   */
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v4.6.0

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
  /**
   * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
   */
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  /**
   * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
   */
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

  /**
   * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
   */
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  /**
   * @dev Returns the number of tokens in ``owner``'s account.
   */
  function balanceOf(address owner) external view returns (uint256 balance);

  /**
   * @dev Returns the owner of the `tokenId` token.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function ownerOf(uint256 tokenId) external view returns (address owner);

  /**
   * @dev Safely transfers `tokenId` token from `from` to `to`.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must exist and be owned by `from`.
   * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) external;

  /**
   * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
   * are aware of the ERC721 protocol to prevent tokens from being forever locked.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must exist and be owned by `from`.
   * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
   * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
   *
   * Emits a {Transfer} event.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  /**
   * @dev Transfers `tokenId` token from `from` to `to`.
   *
   * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
   *
   * Requirements:
   *
   * - `from` cannot be the zero address.
   * - `to` cannot be the zero address.
   * - `tokenId` token must be owned by `from`.
   * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  /**
   * @dev Gives permission to `to` to transfer `tokenId` token to another account.
   * The approval is cleared when the token is transferred.
   *
   * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
   *
   * Requirements:
   *
   * - The caller must own the token or be an approved operator.
   * - `tokenId` must exist.
   *
   * Emits an {Approval} event.
   */
  function approve(address to, uint256 tokenId) external;

  /**
   * @dev Approve or remove `operator` as an operator for the caller.
   * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
   *
   * Requirements:
   *
   * - The `operator` cannot be the caller.
   *
   * Emits an {ApprovalForAll} event.
   */
  function setApprovalForAll(address operator, bool _approved) external;

  /**
   * @dev Returns the account approved for `tokenId` token.
   *
   * Requirements:
   *
   * - `tokenId` must exist.
   */
  function getApproved(uint256 tokenId) external view returns (address operator);

  /**
   * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
   *
   * See {setApprovalForAll}
   */
  function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File contracts/ERC721OA/IERC721OA.sol
pragma solidity ^0.8.4;

interface IERC721OA is IERC721 {
  function createToken(string memory tokenURI) external returns (uint256);

  function royaltyInfo(uint256 _tokenId, uint256 _salePrice)
    external
    view
    returns (address receiver, uint256 royaltyAmount);
}

// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.6.0

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
  // Booleans are more expensive than uint256 or any type that takes up a full
  // word because each write operation emits an extra SLOAD to first read the
  // slot's contents, replace the bits taken up by the boolean, and then write
  // back. This is the compiler's defense against contract upgrades and
  // pointer aliasing, and it cannot be disabled.

  // The values being non-zero value makes deployment a bit more expensive,
  // but in exchange the refund on every call to nonReentrant will be lower in
  // amount. Since refunds are capped to a percentage of the total
  // transaction's gas, it is best to keep them low in cases like this one, to
  // increase the likelihood of the full refund coming into effect.
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;

  uint256 private _status;

  constructor() {
    _status = _NOT_ENTERED;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * Calling a `nonReentrant` function from another `nonReentrant`
   * function is not supported. It is possible to prevent this from happening
   * by making the `nonReentrant` function external, and making it call a
   * `private` function that does the actual work.
   */
  modifier nonReentrant() {
    // On the first call to nonReentrant, _notEntered will be true
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

    // Any calls to nonReentrant after this point will fail
    _status = _ENTERED;

    _;

    // By storing the original value once again, a refund is triggered (see
    // https://eips.ethereum.org/EIPS/eip-2200)
    _status = _NOT_ENTERED;
  }
}

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.6.0

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);

  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `to`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address to, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `from` to `to` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);
}

// File contracts/NFTMarketOA/StorageOA/IStorageOA.sol
pragma solidity ^0.8.4;

interface IStorageOA {
  // Structur of items stored
  struct StorageItem {
    uint256 itemId;
    address nftContract;
    uint256 tokenId;
    address payable owner;
    uint256 price;
    bool onAuction;
    bool onSale;
    uint256 endTime;
    address highestBidder;
    uint256 highestBid;
    address currency;
    bool isActive;
    address stored;
    bool firstSold;
  }

  // Method to get all actives items
  function getItems() external view returns (StorageItem[] memory);

  // Method to get actives items by collection
  function getItemsByCollection(address collectionAddress) external view returns (StorageItem[] memory);

  // Method to get items by owner
  function getItemsByOwner(address addressOwner) external view returns (StorageItem[] memory);

  // Method to get disabled items by owner
  function getDisabledItemsByOwner(address addressOwner) external view returns (StorageItem[] memory);

  function getItem(uint256 itemId) external view returns (StorageItem memory);

  /* Allows other contract to send this contract's nft */
  function transferItem(uint256 itemId, address to) external;

  function setItem(uint256 itemId, StorageItem memory item) external;

  function setItemAuction(
    uint256 itemId,
    address highestBidder,
    uint256 highestBid
  ) external;

  function createItem(
    address nftContract,
    uint256 tokenId,
    bool isActive,
    address ownerItem,
    bool onSale,
    bool onAuction,
    uint256 endTime,
    address currency,
    uint256 price,
    bool firstSold
  ) external;

  function setActiveItem(uint256 itemId, bool isActive) external;
}

// File contracts/utils/ApprovalsGuard.sol
pragma solidity ^0.8.4;

abstract contract ApprovalsGuard {
  // Mapping of approved address to write storage
  mapping(address => bool) private _approvals;
  address internal owner;

  constructor() {
    owner = msg.sender;
  }

  // Modifier to allow only approvals to execute methods
  modifier onlyApprovals() {
    require(_approvals[msg.sender], "You are not allowed to execute this method");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "You are not allowed to execute this method");
    _;
  }

  modifier onlyApprovalsOrOwner() {
    require((msg.sender == owner || _approvals[msg.sender]), "You are not allowed to execute this method");
    _;
  }

  function setApproval(address approveAddress, bool approved) public onlyOwner {
    require(msg.sender == owner, "You are not allowed to execute this function");
    _approvals[approveAddress] = approved;
  }

  function transferOwnership(address to_) external onlyOwner {
    require(msg.sender == owner, "You are not allowed to execute this function");
    owner = to_;
  }
}

// File contracts/NFTMarketOA/Events/IEvents.sol
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
    address currency
  );

  event ListItem(
    address indexed from,
    address indexed to,
    uint256 indexed itemId,
    address nftContract,
    uint256 tokenId,
    uint256 amount,
    address currency
  );

  event SaleItem(
    address indexed from,
    address indexed to,
    uint256 indexed itemId,
    address nftContract,
    uint256 tokenId,
    uint256 amount,
    address currency
  );

  event Cancel(address indexed from, address indexed to, uint256 indexed itemId, address nftContract, uint256 tokenId);
}

// File contracts/NFTMarketOA/OffersOA/OffersOA.sol
pragma solidity ^0.8.4;

contract OffersOA is ReentrancyGuard, ApprovalsGuard, IEvents {
  using Counters for Counters.Counter;
  Counters.Counter private _offerIds;
  address private _addressStorage;
  uint256 private _listingPrice;

  /* Struct to save if user has money to collect */
  struct Offer {
    uint256 offerId;
    uint256 itemId;
    uint256 amount;
    address bidder;
    address currency;
    uint256 endTime;
    bool accepted;
    bool collected;
  }

  mapping(uint256 => Offer) private offers;

  constructor(uint256 listingPrice, address addressStorage) {
    _listingPrice = listingPrice;
    _addressStorage = addressStorage;
  }

  /* Allow users to make an offer */
  function makeOffer(
    uint256 itemId,
    uint256 bidAmount,
    address bidder,
    uint256 endTime,
    address currency
  ) external onlyApprovals {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(itemId);

    IERC721OA erc721 = IERC721OA(item.nftContract);
    address itemOwner = erc721.ownerOf(item.tokenId);

    require(!item.onAuction, "This item is currently on auction");
    require(itemOwner != bidder, "You are the owner of this nft");
    require((bidAmount > 0), "Amount must be greater than 0");

    _offerIds.increment();
    uint256 offerId = _offerIds.current();

    offers[offerId] = Offer(offerId, itemId, bidAmount, bidder, currency, endTime, false, false);

    emit MakeOffer(bidder, itemOwner, itemId, item.nftContract, item.tokenId, bidAmount, endTime, currency);
  }

  /* Allow item's owner to accept offer and recive his profit */
  function acceptOffer(uint256 offerId, address approval) external onlyApprovals nonReentrant {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(offers[offerId].itemId);
    IERC721OA erc721 = IERC721OA(item.nftContract);
    address itemOwner = erc721.ownerOf(item.tokenId);
    require(itemOwner == approval, "You are not the owner of this item");
    require(!item.onAuction, "You cannot accept offer because the item is currently on auction");
    Offer memory offer = offers[offerId];
    require(block.timestamp < offer.endTime, "The offer has already expired");
    require(!offer.accepted, "The offer has already been accepted");
    require(!offer.collected, "Item was already collected");

    IERC20 erc20 = IERC20(offers[offerId].currency);
    if (item.stored == address(0)) {
      erc721.transferFrom(itemOwner, _addressStorage, item.tokenId);
    }

    address royaltiesReceiver;
    uint256 royaltiesAmount;

    {
      try erc721.royaltyInfo(item.tokenId, offer.amount) returns (address receiver, uint256 royaltyAmount) {
        royaltiesReceiver = receiver;
        royaltiesAmount = royaltyAmount;
      } catch {}
    }

    require(erc20.transferFrom(offer.bidder, address(this), offer.amount), "Error at make transaction.");
    if (royaltiesAmount > 0) {
      require(erc20.transfer(royaltiesReceiver, royaltiesAmount), "Transaction failed");
    }
    require(
      erc20.transfer(itemOwner, (offer.amount - ((offer.amount * _listingPrice) / 100) - royaltiesAmount)),
      "Transfer to owner failed"
    );
    require(erc20.transfer(owner, ((offer.amount * _listingPrice) / 100)), "Transfer failed");
    offers[offerId].accepted = true;
    address prevOwner = itemOwner;
    item.owner = payable(offer.bidder);
    iStorage.setItem(item.itemId, item);

    emit SaleItem(prevOwner, offer.bidder, item.itemId, item.nftContract, item.tokenId, offer.amount, offer.currency);
  }

  /* Allows user to claim items */
  function claimItem(uint256 offerId, address claimer) external onlyApprovals {
    IStorageOA iStorage = IStorageOA(_addressStorage);
    IStorageOA.StorageItem memory item = iStorage.getItem(offers[offerId].itemId);
    require(offers[offerId].accepted, "The offer has not been accepted");
    require(claimer == item.owner, "Only the winner can claim the nft.");
    offers[offerId].collected = true;
    iStorage.transferItem(item.itemId, claimer);
  }

  /* Returns item's offers */
  function getOffersByItem(uint256 itemId) external view returns (Offer[] memory) {
    uint256 totalItemCount = _offerIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (offers[i + 1].itemId == itemId) {
        itemCount += 1;
      }
    }

    Offer[] memory items = new Offer[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (offers[i + 1].itemId == itemId) {
        uint256 currentId = i + 1;
        Offer storage currentItem = offers[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Return item's offers currently active */
  function getActiveOffersByItem(uint256 itemId) external view returns (Offer[] memory) {
    uint256 totalItemCount = _offerIds.current();
    uint256 itemCount = 0;
    uint256 currentIndex = 0;

    for (uint256 i = 0; i < totalItemCount; i++) {
      if (offers[i + 1].itemId == itemId && block.timestamp < offers[i + 1].endTime) {
        itemCount += 1;
      }
    }

    Offer[] memory items = new Offer[](itemCount);
    for (uint256 i = 0; i < totalItemCount; i++) {
      if (offers[i + 1].itemId == itemId && block.timestamp < offers[i + 1].endTime) {
        uint256 currentId = i + 1;
        Offer storage currentItem = offers[currentId];
        items[currentIndex] = currentItem;
        currentIndex += 1;
      }
    }
    return items;
  }

  /* Set storage address */
  function setStorageAddress(address addressStorage) public onlyOwner {
    _addressStorage = addressStorage;
  }
}
