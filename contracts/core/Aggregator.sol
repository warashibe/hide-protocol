//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UseConfig.sol";
import "../interfaces/IViewer.sol";
import "../interfaces/IVP.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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
      balances[i] = IERC20(token).balanceOf(_user);
      shares[i] = v().share_sqrt(pairs[i], _user);
      kudos[i] = v().kudos(pairs[i], _user);
    }
  }
}
