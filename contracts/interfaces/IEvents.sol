//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEvents {
  
  function vote(uint _poll, uint _topic, uint _vp, address voter, address token, uint _minted, uint _share, string memory ref) external;
  
  function burn(address nft, uint id, address from, address to, address token, uint reward, uint payback, string memory ref) external;

  function convert(address token, uint share, address holder, uint amount, string memory ref) external;

  function createTopic(address owner, string memory name, string memory id, string memory ref) external;

  function addItem(address owner, address nft, uint id, uint[] memory topics, string memory ref) external;

  function updateItem(address owner, address nft, uint id, uint[] memory topics, string memory ref) external;
  
  function removeItem(address owner, address nft, uint id, string memory ref) external;

}
