//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPool {
  function owner () external view returns (address);
  
  function token () external view returns (address);
  
  function getTotalVP () external view returns (uint);

  function getVP (address _voter) external view returns (uint);

  function available () external view returns (uint);

  function setPoll (uint _amount) external;

  function vote (address _voter, uint _amount) external;
  
  function withdraw(address _to, address _voter, uint _amount) external;
  
}
