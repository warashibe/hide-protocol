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
  
  function infoUser(address _user, address[] memory _tokens) public view returns(uint[] memory balances, address[] memory pairs, address[] memory tokens, uint[] memory shares, uint[] memory kudos, uint[] memory topics){
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
  function getExistPairs(uint[] memory topics, address[] memory _tokens) internal view returns(address[] memory _pairs, uint[] memory _topics, address[] memory tar_tokens){
    uint index = 0;
    _pairs = new address[](topics.length * _tokens.length);
    _topics = new uint[](topics.length * _tokens.length);
    tar_tokens = new address[](topics.length * _tokens.length);
    for(uint i2 = 0; i2 < topics.length; i2++){
      for(uint i4 = 0; i4 < _tokens.length; i4++){
	address pair = v().pairs(_tokens[i4], topics[i2]);
	if(pair != address(0)){
	  _pairs[index] = pair;
	  _topics[index] = topics[i2];
	  tar_tokens[index] = _tokens[i4];
	  index++;
	}
      }
    }
  }
  
  function getVotableTopics(address _nft, uint _id, address _voter, uint[] memory topics, address[] memory _tokens) internal view returns(uint[] memory votableTopics, uint[] memory max_amounts){
    uint i3 = 0;
    (address[] memory _pairs, uint[] memory _topics, ) = getExistPairs(topics, _tokens);
    votableTopics = new uint[](_pairs.length);
    max_amounts = new uint[](_pairs.length);
    for(uint i = 0; i < _pairs.length; i++){
      if(_pairs[i] != address(0)){
	uint balance = IERC20(_pairs[i]).balanceOf(_voter);
	if(balance > 0 && v().burn_limits(v().pair_tokens(_pairs[i])) - v().user_item_burn(msg.sender, _nft, _id, _pairs[i]) > 0 && IERC721(_nft).ownerOf(_id) != msg.sender){
	  votableTopics[i3] = _topics[i];
	  max_amounts[i3] = v().burn_limits(v().pair_tokens(_pairs[i])) - v().user_item_burn(msg.sender, _nft, _id, _pairs[i]);
	  i3 += 1;
	}
      }
    }
  }

  function getVotablePairs(address _nft, uint _id, address _voter, uint[] memory topics, address[] memory _tokens) internal view returns(address[] memory tokens, address[] memory votable_pairs){
    uint i3 = 0;
    (address[] memory _pairs, , address[] memory vtokens) = getExistPairs(topics, _tokens);
    tokens = new address[](_pairs.length);
    votable_pairs = new address[](_pairs.length);
    for(uint i = 0; i < _pairs.length; i++){
      if(_pairs[i] != address(0)){
	uint balance = IERC20(_pairs[i]).balanceOf(_voter);
	if(balance > 0 && v().burn_limits(v().pair_tokens(_pairs[i])) - v().user_item_burn(msg.sender, _nft, _id, _pairs[i]) > 0 && IERC721(_nft).ownerOf(_id) != msg.sender){
	  votable_pairs[i3] = _pairs[i];
	  tokens[i3] = vtokens[i];
	  i3 += 1;
	}
      }
    }
  }

  function infoItem(address _nft, uint _id, address _voter, address[] memory _tokens) public view returns(uint[] memory topics, uint[] memory votableTopics, uint[] memory max_amounts, address[] memory votable_pairs, address[] memory tokens){
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
    (votableTopics, max_amounts) = getVotableTopics(_nft, _id, _voter, topics, _tokens);
    (tokens, votable_pairs) = getVotablePairs(_nft, _id, _voter, topics, _tokens);
  }
  
  function infoDEX(address[] memory pairs, address _holder) public view returns(uint[] memory pools, uint[] memory shares, uint[] memory total_shares, uint[] memory max_mintable, uint[] memory per){
    pools = new uint[](pairs.length);
    shares = new uint[](pairs.length);
    total_shares = new uint[](pairs.length);
    max_mintable = new uint[](pairs.length);
    per = new uint[](pairs.length);
    for(uint i = 0; i < pairs.length; i++){
      pools[i] = v().getConvertible(pairs[i]);
      shares[i] = v().balanceOf(pairs[i], _holder);
      total_shares[i] = v().totalSupply(pairs[i]);
      max_mintable[i] = shares[i] == 0 ? 0 : v().getConvertibleAmount(pairs[i], shares[i], _holder);
      per[i] = max_mintable[i] == 0 ? 0 : max_mintable[i] * 10 ** 9 / shares[i];
    }
  }
  
  function infoBudgets(address[] memory pairs) public view returns(uint[] memory budgets, uint[] memory topics, string[] memory topic_ids, address[] memory tokens){
    budgets = new uint[](pairs.length);
    topics = new uint[](pairs.length);
    topic_ids = new string[](pairs.length);
    tokens = new address[](pairs.length);
    for(uint i = 0; i < pairs.length; i++){
      budgets[i] = v().getConvertible(pairs[i]) + IERC20(pairs[i]).totalSupply();
      topics[i] = v().pair_topics(pairs[i]);
      topic_ids[i] = v().topic_names(topics[i]);
      tokens[i] = v().pair_tokens(pairs[i]);
    }
  }

}
