// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

abstract contract ApprovalsGuardDynamicOwner {
  // Mapping of approved address to write storage
  mapping(address => bool) private _approvals;

  // Mapping of manager addresses
  address internal manager;
  address private _owner;

  constructor(address owner_) {
    _owner = owner_;
    manager = msg.sender;
  }

  // Modifier to allow only approvals to execute methods
  modifier onlyApprovals() {
    require(_approvals[msg.sender], "You are not allowed to execute this method");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner, "You are not allowed to execute this method");
    _;
  }

  modifier onlyManagerOrOwner() {
    require((msg.sender == _owner || msg.sender == manager), "You are not allowed to execute this method");
    _;
  }

  modifier onlyApprovalsOrOwner() {
    require((msg.sender == _owner || _approvals[msg.sender]), "You are not allowed to execute this method");
    _;
  }

  function setApproval(address approveAddress, bool approved) public onlyManagerOrOwner {
    _setApproval(approveAddress, approved);
  }

  function _setApproval(address approveAddress, bool approved) internal {
    _approvals[approveAddress] = approved;
  }

  function transferOwnership(address to_) external onlyOwner {
    _owner = to_;
  }

  function owner() public view virtual returns (address) {
    return _owner;
  }
}
