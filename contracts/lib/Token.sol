//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

  constructor(string memory _name, string memory _sym, uint _amount) ERC20(_name, _sym) {
    _mint(msg.sender, _amount);
  }

}
