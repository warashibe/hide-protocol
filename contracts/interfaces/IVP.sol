//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVP {
  function owner () external view returns (address);
  
  function getTotalVP () external view returns (uint);

  function getVP (address _voter) external view returns (uint);

  function vote (address _voter, uint _amount) external;
}
