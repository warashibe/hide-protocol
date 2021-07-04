//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEvents {
  
  function vote(uint _poll, uint _topic, uint _vp, address voter, address token, uint _minted, uint _share) external;
  
  function burn(address nft, uint id, address from, address to, address token, uint reward, uint payback) external;

  function convert(address token, uint share, address holder, uint amount) external;
}
