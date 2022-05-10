// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

import "./AuctionsOA/IAuctionsOA.sol";
import "./SalesOA/ISalesOA.sol";
import "./StorageOA/IStorageOA.sol";

contract OpenArtMarketPlace {
    address private address_storage;
    address private address_sales;
    address private address_auctions;
    address private owner;

    constructor (address _address_storage, address _address_sales, address _address_auctions){
        address_storage = _address_storage;
        address_sales = _address_sales;
        address_auctions =_address_auctions;
        owner = msg.sender;
    }

    /* Modifier to only allow owner to execute function */
    modifier onlyOwner {
        require(msg.sender == owner, "You are not allowed to execute this method");
        _;
    }

    /* Change storage contract address */
    function setStorageAddress(address _address_storage) onlyOwner public {
        address_storage = _address_storage;
    }

    /* Change sales contract address */
    function setSalesAddress(address _address_sales) onlyOwner public {
        address_sales = _address_sales;
    }

    /* Change auctions contract address */
    function setAuctionsAddress(address _address_auctions) onlyOwner public {
        address_auctions = _address_auctions;
    }
}