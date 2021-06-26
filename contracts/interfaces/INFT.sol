//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INFT {
  function mint (address _to, string memory _url) external returns(uint);
}
