//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Collector is Ownable, AccessControl {

  bytes32 public constant AGENT = keccak256("AGENT");
  
  address public collector;
  address[] public tokens;
  uint[] public fees;

  constructor(address[] memory _tokens, uint[] memory _fees, address _collector) {
    tokens = _tokens;
    fees = _fees;
    collector = _collector;
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }
  
  function setTokens(address[] memory _tokens, uint[] memory _fees) public onlyOwner {
    tokens = _tokens;
    fees = _fees;
  }
  
  function setCollector(address _collector) public onlyOwner {
    collector = _collector;
  }

  function addAgent(address _agent) public onlyOwner {
    grantRole(AGENT, _agent);
  }
  
  function removeAgent(address _agent) public onlyOwner {
    revokeRole(AGENT, _agent);
  }

  function collect(address sender) external onlyRole(AGENT) {
    bool paid = false;
    for(uint i = 0; i < tokens.length; i++){
      if(IERC20(tokens[i]).balanceOf(sender) >= fees[i]){
	IERC20(tokens[i]).transferFrom(sender, collector, fees[i]);
	paid = true;
	break;
      }
    }
    require(paid, "fee could not be paid");
  }

}
