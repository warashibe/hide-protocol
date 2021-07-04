//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../core/UseConfig.sol";

contract Events is Ownable, UseConfig, AccessControlEnumerable {
  
  bytes32 public constant EMITTER_ROLE = keccak256("EMITTER_ROLE");

  event Vote(uint indexed poll, uint indexed topic, uint vp, address indexed voter, address token, uint minted, uint share);
  
  event Burn(address indexed nft, uint indexed id, address indexed burner, address owner, address token, uint reward, uint payback);

  event Convert(address indexed token, uint share, address holder, uint amount);

  modifier onlyEmitter() {
    require(hasRole(EMITTER_ROLE,msg.sender), "only EMITTER can execute");
    _;
  }
  
  constructor(address _addr) UseConfig(_addr) {
      _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
      _setupRole(EMITTER_ROLE, _msgSender());
  }

  function vote(uint _poll, uint _topic, uint _vp, address voter, address token, uint _minted, uint _share) external onlyEmitter {
    emit Vote(_poll, _topic, _vp, voter, token, _minted, _share);
  }

  function burn(address nft, uint id, address from, address to, address token, uint reward, uint payback) external onlyEmitter {
    emit Burn(nft, id, from, to, token, reward, payback);
  }

  function convert(address token, uint share, address holder, uint amount) external onlyEmitter {
    emit Convert(token, share, holder, amount);
  }
  
  function addEmitter(address _emmiter) public onlyOwner {
    grantRole(EMITTER_ROLE, _emmiter);
  }
  
  function removeEmitter(address _emmiter) public onlyOwner {
    revokeRole(EMITTER_ROLE, _emmiter);
  }
  
}
