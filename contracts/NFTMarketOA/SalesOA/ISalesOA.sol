// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface ISalesOA {
    /* Return allowance in a specific ERC20 token */
    function myallowance(address currency) external returns (uint);

    /* Returns the listing price of the contract */
    function getListingPrice() external view returns (uint256);

    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketSale(uint256 itemId, address buyer) external payable;

    /* Change listing price in hundredths*/
    function setListingPrice (uint percent) external;

    /* Put on sale */
    function activateSale(uint256 itemId, uint256 price, address currency, address seller) external;

    /* Remove from sale */
    function deactivateSale(uint256 itemId, address seller) external;

    /* Set storage address */
    function setStorageAddress (address _address_storage) external;
}
