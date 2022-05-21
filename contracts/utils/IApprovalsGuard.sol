// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.4;

interface IApprovalsGuard {
  function setApproval(address approveAddress, bool approved) external;
}
