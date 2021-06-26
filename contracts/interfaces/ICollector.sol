//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICollector {
  function collect(address sender) external;
  function token() external returns(address);
}
