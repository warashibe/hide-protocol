//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../lib/NFT.sol";
import "../interfaces/IWithdraw.sol";
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
    ICollector(a().collector()).collect(msgSender());
    m().setItemTopics(_nft, _id, _topics);
  }
  
  function addItem (address _nft, uint _id, uint[] memory _topics) public {
    require(msgSender() == IERC721(_nft).ownerOf(_id), "item must be registered by owner");
    require(v().items(_nft, _id) == false, "item already registered");
    m().setItemTopics(_nft, _id, _topics);
    m().setItems(_nft, _id, true);
  }
  
  function removeItem (address _nft, uint _id) public {
    require(msgSender() == IERC721(_nft).ownerOf(_id), "item must be registered by owner");
    require(v().items(_nft, _id) == true, "item not registered");
    ICollector(a().collector()).collect(msgSender());
    m().setItems(_nft, _id, false);
    m().deleteItemTopics(_nft, _id);
  }
  
  function createItem (string memory _str, uint[] memory _topics) public {
    (, uint _id) = v().item_indexes(_str);
    require(_id == 0, "item already registered");
    ICollector(a().collector()).collect(msgSender());
    uint id = NFT(nft).mint(msgSender(), _str);
    m().setItemIndexes(_str, nft, id);
    addItem(nft, id, _topics);
  }
  
  function burnFor (address _nft, uint _id, address _pair, uint _topic, uint _amount) public {
    require(v().items(_nft, _id), "item not registered");
    require(msgSender() != IERC721(_nft).ownerOf(_id), "item owner cannot vote");
    uint limit = v().burn_limits(v().pair_tokens(_pair));
    require(limit == 0 || _amount <= limit, "amount is larger than limit");
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
    ICollector(a().collector()).collect(msgSender());
    address item_owner = NFT(_nft).ownerOf(_id);
    uint _reward = _amount * v().creator_percentage() / 10000;
    ERC20Burnable(_pair).burnFrom(msgSender(),_amount);
    IWithdraw(a().withdraw()).withdraw(item_owner, msgSender(), _amount, v().pair_tokens(_pair));
    m().setTotalKudos(_pair, v().total_kudos(_pair) + _amount);
    addShare(_pair, _reward, item_owner);
    addShare(_pair, _amount - _reward, msgSender());
    c().pushUserPairs(item_owner, _pair);
    c().pushUserPairs(msgSender(), _pair);
    m().pushItemPairs(_nft, _id, _pair);
    e().burn(_nft, _id, msgSender(), item_owner, _pair, _reward, _amount - _reward);
  }
  
  function addShare(address _pair, uint _amount, address _holder) internal {
    uint _balance = v().balanceOf(_pair, _holder);
    uint _supply = v().total_share_sqrt(_pair);
    uint _last_balance = v().share_sqrt(_pair, _holder);
    uint _new_balance = u().sqrt(_balance + _amount);
    uint diff = _new_balance - _last_balance;
    uint _totalSupply = v().totalSupply(_pair) + _balance + diff - _last_balance;
    uint _lastSupply = _supply + diff;
    m().setTotalShareSqrt(_pair, _totalSupply);
    m().setShareSqrt(_pair, _holder, _new_balance);
    m().setLastBlocks(_pair, _holder, block.number);
    m().setLastBlock(_pair, block.number);
    m().setLastSupply(_pair, _lastSupply);
  }
  
}
