//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../lib/ERC20Permit.sol";
import "./UseConfig.sol";

contract Topic is Ownable, ERC20Permit, UseConfig {
  
  constructor(string memory _name, string memory _sym, uint _numerator, uint _denominator, address _addr) ERC20Freigeld(_name, _sym) ERC20Permit(_name) UseConfig(_addr) {
    _setRate(_numerator, _denominator);
  }
  
  function setRate (uint256 _numerator, uint256 _denominator) external {
    v().onlyGovernance(msg.sender);
    _setRate(_numerator, _denominator);
  }
  
  function mint (address _to, uint _amount) external {
    v().onlyGovernanceOrDEX(msg.sender);
    _mint(_to, _amount);
  }
  
  function burn(uint256 amount) public virtual {
    _burn(_msgSender(), amount);
  }

  function burnFrom(address account, uint256 amount) public virtual {
    uint256 currentAllowance = allowance(account, _msgSender());
    require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
    _approve(account, _msgSender(), currentAllowance - amount);
    _burn(account, amount);
  }
}
