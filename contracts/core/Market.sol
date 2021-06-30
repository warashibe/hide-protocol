//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../lib/NFT.sol";
import "../dev/Pool.sol";
import "../interfaces/ICollector.sol";
import "./UseConfig.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../lib/EIP712MetaTransaction.sol";

contract Market is Ownable, UseConfig, EIP712MetaTransaction {
  address public nft;
  constructor(address _nft, address _addr) UseConfig(_addr) EIP712MetaTransaction("Market", "1") {
    nft = _nft;
  }
  
  function updateItem (address _nft, uint _id, uint[] memory _topics) public {
    require(msgSender() == IERC721(_nft).ownerOf(_id), "item must be registered by owner");
    require(v().items(_nft, _id) == true, "item not registered");
    c().setItemTopics(_nft, _id, _topics);
  }
  
  function addItem (address _nft, uint _id, uint[] memory _topics) public {
    require(msgSender() == IERC721(_nft).ownerOf(_id), "item must be registered by owner");
    require(v().items(_nft, _id) == false, "item already registered");
    c().setItemTopics(_nft, _id, _topics);
    c().setItems(_nft, _id, true);
  }
  
  function removeItem (address _nft, uint _id) public {
    c().setItems(_nft, _id, false);
    c().deleteItemTopics(_nft, _id);
  }
  
  function createItem (string memory _str, uint[] memory _topics) public {
    (address _nft, uint _id) = v().item_indexes(_str);
    require(_id == 0, "item already registered");
    ICollector(a().collector()).collect(msgSender());
    uint id = NFT(nft).mint(msgSender(), _str);
    c().setItemIndexes(_str, nft, id);
    addItem(nft, id, _topics);
  }
  
  function burnFor (address _nft, uint _id, address _pool, uint _topic, uint _amount) public {
    require(v().items(_nft, _id), "item not registered");
    ICollector(a().collector()).collect(msgSender());
    bool existsTopic = v().free_topic() == _topic ? true : false;
    if(!existsTopic){
      for(uint i = 0; i < v().item_topics(_nft, _id).length; i++){
	if(v().item_topics(_nft, _id)[i] == _topic){
	  existsTopic = true;
	  break;
	}
      }
    }
    require(existsTopic, "item does not have the topic");
    address pair = v().getPair(_pool, _topic);
    address item_owner = NFT(_nft).ownerOf(_id);
    uint _reward = _amount * v().creator_percentage() / 10000;
    ERC20Burnable(pair).burnFrom(msgSender(),_amount);
    Pool(_pool).withdraw(item_owner, msgSender(), _amount);
    c().setTotalShare(pair, v().total_share(pair) + _amount);
    c().setTotalKudos(pair, v().total_kudos(pair) + _amount);
    addShare(pair, _reward, item_owner);
    addShare(pair, _amount - _reward, msgSender());
  }
  
  function addShare(address _pair, uint _amount, address _holder) internal {
    uint current_share = v().share(_pair, _holder);
    c().setShare(_pair, _holder, current_share + _amount);
    c().setKudos(_pair, _holder, v().kudos(_pair, _holder) + _amount);
    uint current_share_sqrt = u().sqrt(current_share);
    uint new_share_sqrt = u().sqrt(current_share + _amount);
    c().setShareSqrt(_pair, _holder, new_share_sqrt);
    uint diff = new_share_sqrt - current_share_sqrt;
    c().setTotalShareSqrt(_pair, v().total_share_sqrt(_pair) + diff);
    
  }
  
}
