//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../core/UseConfig.sol";

contract Pool is Ownable, UseConfig {
  address public token;
  mapping(address => uint) used_vp;
  uint public total_used_vp;

  constructor(address _token, address _addr) UseConfig(_addr) {
    token = _token;
  }

  function getTotalVP () public view returns (uint _vp) {
    _vp = 300 * 10 ** 18 - total_used_vp;
  }

  function getVP (address _voter) public view returns (uint _vp) {
    _vp = IERC20(token).balanceOf(_voter) - used_vp[_voter];
  }

  function vote (address _voter, uint _amount) external {
    v().onlyGovernance(msg.sender);
    require(getVP(_voter) >= _amount, "VP not enough");
    used_vp[_voter] += _amount;
    total_used_vp += _amount;
  }
  
}
