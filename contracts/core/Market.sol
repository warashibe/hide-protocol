//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
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
  
  function updateItem (address _nft, uint _id, uint[] memory _topics, string memory _ref) public {
    require(msgSender() == IERC721(_nft).ownerOf(_id), "item must be registered by owner");
    require(v().items(_nft, _id) == true, "item not registered");
    ICollector(a().collector()).collect(msgSender());
    m().setItemTopics(_nft, _id, _topics);
    e().updateItem(msgSender(), _nft, _id, _topics, _ref);
  }
  
  function addItem (address _nft, uint _id, uint[] memory _topics, string memory _ref) public {
    require(msgSender() == IERC721(_nft).ownerOf(_id), "item must be registered by owner");
    require(v().items(_nft, _id) == false, "item already registered");
    m().setItemTopics(_nft, _id, _topics);
    m().setItems(_nft, _id, true);
    e().addItem(msgSender(), _nft, _id, _topics, _ref);
  }
  
  function removeItem (address _nft, uint _id, string memory _ref) public {
    require(msgSender() == IERC721(_nft).ownerOf(_id), "item must be registered by owner");
    require(v().items(_nft, _id) == true, "item not registered");
    ICollector(a().collector()).collect(msgSender());
    m().setItems(_nft, _id, false);
    m().deleteItemTopics(_nft, _id);
    e().removeItem(msgSender(), _nft, _id, _ref);
  }
  
  function createItem (string memory _str, uint[] memory _topics, string memory _ref) public {
    (, uint _id) = v().item_indexes(_str);
    require(_id == 0, "item already registered");
    ICollector(a().collector()).collect(msgSender());
    uint id = NFT(nft).mint(msgSender(), _str);
    m().setItemIndexes(_str, nft, id);
    addItem(nft, id, _topics, _ref);
  }
  function _isBurnable(address _nft, uint _id, address _pair, uint _amount) internal view {
    require(v().items(_nft, _id), "item not registered");
    require(msgSender() != IERC721(_nft).ownerOf(_id), "item owner cannot vote");
    uint _topic = v().pair_topics(_pair);
    uint limit = v().burn_limits(v().pair_tokens(_pair));
    uint burned = v().user_item_burn(msgSender(), _nft, _id, _pair);
    require(limit == 0 || _amount <= limit - burned, "amount is larger than limit");
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
  }
  
  function burnFor (address _nft, uint _id, address _pair, uint _amount, string memory ref) public {
    _isBurnable(_nft, _id, _pair, _amount);
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
    uint burned = v().user_item_burn(msgSender(), _nft, _id, _pair);
    m().setUserItemBurn(msgSender(), _nft, _id, _pair, burned + _amount);
    e().burn(_nft, _id, msgSender(), item_owner, _pair, _reward, _amount - _reward, ref);
  }
  
  function addShare(address _pair, uint _amount, address _holder) internal {
    uint _balance = v().balanceOf(_pair, _holder);
    uint _new_balance = u().sqrt(_balance * _balance + _amount);
    uint diff = _new_balance - _balance;
    uint share = v().toShare(_pair, diff);
    uint _supply = v().totalSupply(_pair);
    bool reset = _supply == 0 || share / _supply > 10 ** 15;
    if(reset) _supply = 0;
    if(reset) m().setGenesises(_pair, block.number);
    m().setTotalShare(_pair, reset ? share : v().total_share(_pair) + share);
    m().setTotalShareSqrt(_pair, _supply + diff);
    m().setShareSqrt(_pair, _holder, v().shareOf(_pair, _holder) + share); 
    m().setLastBlocks(_pair, _holder, block.number);
    m().setLastBlock(_pair, block.number);
  }

}
