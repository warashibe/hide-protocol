//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUtils {

  function concat( string memory a, string memory b) external pure returns(string memory);

  function includes (uint[] memory _arr, uint _item) external pure returns(bool);
  
  function sqrt(uint x) external pure returns (uint);
  
}
