//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../core/UseConfig.sol";

contract Events is Ownable, UseConfig, AccessControlEnumerable {
  
  bytes32 public constant EMITTER_ROLE = keccak256("EMITTER_ROLE");

  event Vote(uint indexed poll, uint indexed topic, uint vp, address indexed voter, address token, uint minted, uint share, string ref);
  
  event Burn(address indexed nft, uint indexed id, address indexed burner, address owner, address token, uint reward, uint payback, string ref);

  event Convert(address indexed token, uint share, address holder, uint amount, string ref);

  event CreateTopic(address indexed owner, string name, string id, string ref);

  event AddItem(address indexed owner, address indexed nft, uint id, uint[] topics, string ref);

  event UpdateItem(address indexed owner, address indexed nft, uint id, uint[] topics, string ref);

  event RemoveItem(address indexed owner, address indexed nft, uint id, string ref);

  modifier onlyEmitter() {
    require(hasRole(EMITTER_ROLE,msg.sender), "only EMITTER can execute");
    _;
  }
  
  constructor(address _addr) UseConfig(_addr) {
      _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
      _setupRole(EMITTER_ROLE, _msgSender());
  }

  function vote(uint _poll, uint _topic, uint _vp, address voter, address token, uint _minted, uint _share, string memory ref) external onlyEmitter {
    emit Vote(_poll, _topic, _vp, voter, token, _minted, _share, ref);
  }

  function burn(address nft, uint id, address from, address to, address token, uint reward, uint payback, string memory ref) external onlyEmitter {
    emit Burn(nft, id, from, to, token, reward, payback, ref);
  }

  function convert(address token, uint share, address holder, uint amount, string memory ref) external onlyEmitter {
    emit Convert(token, share, holder, amount, ref);
  }

  function createTopic(address owner, string memory name, string memory id, string memory ref) external onlyEmitter {
    emit CreateTopic(owner, name, id, ref);
  }

  function addItem(address owner, address nft, uint id, uint[] memory topics, string memory ref) external onlyEmitter {
    emit AddItem(owner, nft, id, topics, ref);
  }  

  function updateItem(address owner, address nft, uint id, uint[] memory topics, string memory ref) external onlyEmitter {
    emit UpdateItem(owner, nft, id, topics, ref);
  }
  
  function removeItem(address owner, address nft, uint id, string memory ref) external onlyEmitter {
    emit RemoveItem(owner, nft, id, ref);
  }  
  
  function addEmitter(address _emmiter) public onlyOwner {
    grantRole(EMITTER_ROLE, _emmiter);
  }
  
  function removeEmitter(address _emmiter) public onlyOwner {
    revokeRole(EMITTER_ROLE, _emmiter);
  }
  
}
