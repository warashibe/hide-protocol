//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../core/UseConfig.sol";
import "../dev/IWPVP.sol";

contract JPYCVP is Ownable, UseConfig {
  mapping(address => uint) public used_vp;
  uint public total_used_vp;
  address public vp;
  
  constructor(address _addr, address _addr2) UseConfig(_addr2) {
    vp = _addr;
  }

  function getTotalVP () public view returns (uint) {
    return IWPVP(vp).totalWP() - total_used_vp;
  }

  function getVP (address _voter) public view returns (uint) {
    return IWPVP(vp).earnings(_voter) - used_vp[_voter];
  }

  function vote (address _voter, uint _amount) external {
    mod().onlyGovernance(msg.sender);
    require(getVP(_voter) >= _amount, "VP not enough");
    used_vp[_voter] += _amount;
    total_used_vp += _amount;
  }
  
}
