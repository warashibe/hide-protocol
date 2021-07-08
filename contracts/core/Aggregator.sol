//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UseConfig.sol";
import "../interfaces/IViewer.sol";
import "../interfaces/IVP.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../lib/NFT.sol";

contract Aggregator is UseConfig {
  constructor(address _addr) UseConfig(_addr){}

  function infoTopic(string memory _name) public view returns(uint topic, address[] memory pairs, address[] memory tokens, uint[] memory budgets){
    topic = v().topic_indexes(_name);
    pairs = v().topic_pairs(topic);
    tokens = new address[](pairs.length);
    budgets = new uint[](pairs.length);
    for(uint i = 0; i < pairs.length; i++){
      address token = v().pair_tokens(pairs[i]);
      tokens[i] = token;
      budgets[i] = IERC20(token).totalSupply() + v().claimable(pairs[i]);
    }
  }
  
  function infoVote(uint _poll, uint _amount, uint _topic, address _voter) public view returns(uint[4] memory vp ,uint[2] memory amounts, uint[2] memory budgets, uint[2] memory balances){
    Poll memory p = v().polls(_poll);
    vp[0] = IVP(p.pool).getVP(_voter);
    vp[1] = IVP(p.pool).getTotalVP();
    vp[2] = p.total_votes;
    vp[3] = v().poll_topic_votes(_poll, _topic);
    (uint mintable,  uint converted) = v().getMintable(_poll, _amount, _topic);
    amounts[0] = mintable;
    amounts[1] = converted;
    budgets[0] = IERC20(v().getPair(_poll, _topic)).totalSupply() + v().claimable(v().getPair(_poll, _topic));
    budgets[1] = budgets[0] + converted;
    balances[0] = IERC20(v().getPair(_poll, _topic)).balanceOf(_voter);
    balances[1] = balances[0] + mintable;
  }
  
  function infoUser(address _user) public view returns(uint[] memory balances, address[] memory pairs, address[] memory tokens, uint[] memory shares, uint[] memory kudos, uint[] memory topics){
    pairs = v().user_pairs(_user);
    tokens = new address[](pairs.length);
    topics = new uint[](pairs.length);
    balances = new uint[](pairs.length);
    shares = new uint[](pairs.length);
    kudos = new uint[](pairs.length);
    for(uint i = 0; i < pairs.length; i++){
      address token = v().pair_tokens(pairs[i]);
      tokens[i] = token;
      topics[i] = v().pair_topics(pairs[i]);
      balances[i] = IERC20(pairs[i]).balanceOf(_user);
      shares[i] = v().share_sqrt(pairs[i], _user);
      kudos[i] = v().kudos(pairs[i], _user);
    }
  }
  function getTopicLength(address _nft, uint _id, address _voter, uint[] memory topics) internal view returns(uint len){
    address[] memory user_pairs = v().user_pairs(_voter);
    for(uint i = 0; i < user_pairs.length; i++){
      for(uint i2 = 0; i2 < topics.length; i2++){
	if(v().pair_topics(user_pairs[i]) == topics[i2]){
	  uint balance = IERC20(user_pairs[i]).balanceOf(_voter);
	  if(balance > 0 && v().burn_limits(v().pair_tokens(user_pairs[i])) - v().user_item_burn(msg.sender, _nft, _id, user_pairs[i]) > 0 && IERC721(_nft).ownerOf(_id) != msg.sender){
	    len += 1;
	  }
	}
      }
    }

  }
  
  function getVotableTopics(address _nft, uint _id, address _voter, uint[] memory topics, uint len) internal view returns(uint[] memory votableTopics, uint[] memory max_amounts){
    address[] memory user_pairs = v().user_pairs(_voter);
    votableTopics = new uint[](len);
    max_amounts = new uint[](len);
    uint i3 = 0;
    for(uint i = 0; i < user_pairs.length; i++){
      for(uint i2 = 0; i2 < topics.length; i2++){
	if(v().pair_topics(user_pairs[i]) == topics[i2]){
	  uint balance = IERC20(user_pairs[i]).balanceOf(_voter);
	  if(balance > 0 && v().burn_limits(v().pair_tokens(user_pairs[i])) - v().user_item_burn(msg.sender, _nft, _id, user_pairs[i]) > 0){
	    votableTopics[i3] = topics[i2];
	    max_amounts[i3] = v().burn_limits(v().pair_tokens(user_pairs[i])) - v().user_item_burn(msg.sender, _nft, _id, user_pairs[i]);
	    i3 += 1;
	  }
	}
      }
    }
  }

  function getVotablePairs(address _nft, uint _id, address _voter, uint[] memory topics, uint len) internal view returns(address[] memory votable_pairs){
    address[] memory user_pairs = v().user_pairs(_voter);
    votable_pairs = new address[](len);
    uint i3 = 0;
    for(uint i = 0; i < user_pairs.length; i++){
      for(uint i2 = 0; i2 < topics.length; i2++){
	if(v().pair_topics(user_pairs[i]) == topics[i2]){
	  uint balance = IERC20(user_pairs[i]).balanceOf(_voter);
	  if(balance > 0 && v().burn_limits(v().pair_tokens(user_pairs[i])) - v().user_item_burn(msg.sender, _nft, _id, user_pairs[i]) > 0){
	    votable_pairs[i3] = user_pairs[i];
	    i3 += 1;
	  }
	}
      }
    }
  }

  function infoItem(address _nft, uint _id, address _voter) public view returns(uint[] memory topics, uint[] memory votableTopics, uint[] memory max_amounts, address[] memory votable_pairs){
    uint[] memory _topics = v().item_topics(_nft, _id);
    bool existsFree = false;
    for(uint i = 0; i < _topics.length; i++){
      if(_topics[i] == v().free_topic()){
	existsFree = true;
	break;
      }
    }
    topics = new uint[](existsFree ? _topics.length : _topics.length + 1);
    for(uint i = 0; i < _topics.length; i++){
      topics[i] = _topics[i];
    }
    if(!existsFree){
      topics[topics.length - 1] = v().free_topic();
    }
    uint len = getTopicLength(_nft, _id, _voter, topics);
    (votableTopics, max_amounts) = getVotableTopics(_nft, _id, _voter, topics, len);
    votable_pairs = getVotablePairs(_nft, _id, _voter, topics, len);
  }

}
