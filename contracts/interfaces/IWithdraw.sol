//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWithdraw {
  function withdraw(address _to, address _voter, uint _amount, address _token) external;
  
}
