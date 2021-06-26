//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFactory {
  function issue (string memory _name, string memory _sym, address _config) external returns (address _token);
}
