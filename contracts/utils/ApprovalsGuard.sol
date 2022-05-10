// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

abstract contract ApprovalsGuard {
        // Mapping of approved address to write storage
    mapping(address => bool) private _approvals;
    address internal owner;

    constructor() {
        owner = msg.sender;
    }

    // Modifier to allow only approvals to execute methods
    modifier onlyApprovals {
        require(_approvals[msg.sender], "You are not allowed to execute this method");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You are not allowed to execute this method");
        _;
    }

    function setApproval(address approve_address, bool approved) onlyOwner public {
        require(msg.sender == owner, "You are not allowed to execute this function");
        _approvals[approve_address] = approved;
    }
}