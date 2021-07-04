//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWPVP {
  function totalWP() external view returns(uint);
  
  function earnings(address _addr) external view returns(uint);
  
  function paybacks(address _addr) external view returns(uint);
  
}
