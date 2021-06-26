//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFT.sol";
import "./Pool.sol";
import "./interfaces/ICollector.sol";
import "./UseConfig.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./EIP712MetaTransaction.sol";

contract Market is Ownable, UseConfig, EIP712MetaTransaction {
  address public nft;
  mapping(address => mapping(uint => uint[])) topics;
  mapping(address => mapping(uint => bool)) items;
  constructor(address _nft, address _config) UseConfig(_config) EIP712MetaTransaction("Market", "1") {
    nft = _nft;
  }
  
  function updateItem (address _nft, uint _id, uint[] memory _topics) public {
    require(msgSender() == IERC721(_nft).ownerOf(_id), "item must be registered by owner");
    require(items[_nft][_id] == true, "item not registered");
    topics[_nft][_id] = _topics;
  }
  
  function addItem (address _nft, uint _id, uint[] memory _topics) public {
    require(msgSender() == IERC721(_nft).ownerOf(_id), "item must be registered by owner");
    require(items[_nft][_id] == false, "item already registered");
    topics[_nft][_id] = _topics;
    items[_nft][_id] = true;
  }
  
  function removeItem (address _nft, uint _id) public {
    items[_nft][_id] = false;
    delete topics[_nft][_id];
  }
  
  function createItem (string memory tokenURI, uint[] memory _topics) public {
    ICollector(c().collector()).collect(msgSender());
    uint id = NFT(nft).mint(msgSender(), tokenURI);
    addItem(nft, id, _topics);
  }
  
  function burnFor (address _nft, uint _id, address _pool, uint _topic, uint _amount) public {
    require(items[_nft][_id], "item not registered");
    ICollector(c().collector()).collect(msgSender());
    bool existsTopic = c().free_topic() == _topic ? true : false;
    if(!existsTopic){
      for(uint i = 0; i < topics[_nft][_id].length; i++){
	if(topics[_nft][_id][i] == _topic){
	  existsTopic = true;
	  break;
	}
      }
    }
    require(existsTopic, "item does not have the topic");
    address pair = c().getPair(_pool, _topic);
    address item_owner = NFT(_nft).ownerOf(_id);
    uint _reward = _amount * c().creator_percentage() / 10000;
    ERC20Burnable(pair).burnFrom(msgSender(),_amount);
    Pool(_pool).withdraw(item_owner, msgSender(), _amount);
    c().setTotalShare(pair, c().total_share(pair) + _amount);
    c().setTotalKudos(pair, c().total_kudos(pair) + _amount);
    addShare(pair, _reward, item_owner);
    addShare(pair, _amount - _reward, msgSender());
  }
  
  function addShare(address _pair, uint _amount, address _holder) internal {
    uint current_share = c().share(_pair, _holder);
    c().setShare(_pair, _holder, current_share + _amount);
    c().setKudos(_pair, _holder, c().kudos(_pair, _holder) + _amount);
    uint current_share_sqrt = c().sqrt(current_share);
    uint new_share_sqrt = c().sqrt(current_share + _amount);
    c().setShareSqrt(_pair, _holder, new_share_sqrt);
    uint diff = new_share_sqrt - current_share_sqrt;
    c().setTotalShareSqrt(_pair, c().total_share_sqrt(_pair) + diff);
    
  }
  
}
