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
}
