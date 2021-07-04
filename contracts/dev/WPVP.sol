//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract WPVP is AccessControl, Ownable  {
  bytes32 public constant EDITOR_ROLE = keccak256("EDITOR_ROLE");
  uint public totalWP;
  mapping(address => uint) public earnings;
  mapping(address => uint) public paybacks;
  
  constructor() public {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(EDITOR_ROLE, _msgSender());
  }

  modifier onlyEditor() {
    require(hasRole(EDITOR_ROLE,msg.sender), "only EDITOR can execute");
    _;
  }

  function addEditor(address _editor) public onlyOwner {
    grantRole(EDITOR_ROLE, _editor);
  }

  function removeEditor(address _editor) public onlyOwner {
    revokeRole(EDITOR_ROLE, _editor);
  }
  
  function recordWP(address from, address to, uint amount) external onlyEditor{
    earnings[from] += amount;
    paybacks[to] += amount;
    totalWP += amount;
  }

  function setTotalWP(uint amount) external onlyOwner {
    totalWP = amount;
  }
  
  function bulkRecordWP(address[] memory from, address[] memory to, uint[] memory _earnings, uint[] memory _paybacks) public onlyOwner {
    require(from.length == _earnings.length && to.length == _paybacks.length, "array lengths must be the same");
    for(uint i = 0;i < from.length;i++){
      earnings[from[i]] = _earnings[i];
    }
    for(uint i = 0;i < to.length;i++){
      paybacks[to[i]] = _paybacks[i];
    }
  }

}
