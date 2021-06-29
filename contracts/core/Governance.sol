//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UseConfig.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../lib/EIP712MetaTransaction.sol";
import "../interfaces/IPool.sol";
import "../interfaces/ICollector.sol";
import "../interfaces/ITopic.sol";
import "../interfaces/IFactory.sol";

contract Governance is Ownable, UseConfig, EIP712MetaTransaction {
  
  constructor(address _addr) UseConfig(_addr) EIP712MetaTransaction("Governance", "1") {}

  function mint (uint _poll, uint _amount, uint _topic) public {
    v().existsPoll(_poll);
    v().existsTopic(_topic);
    Poll memory _Poll = v().getPoll(_poll);
    require (_Poll.phase == 2, "mint not allowed");
    uint _claimable = v().getClaimable(_poll, msgSender());
    require (_claimable >= _amount, "amount too big");
    ICollector(a().collector()).collect(msgSender());
    _setPair(_Poll.pool, _topic);
    c().setPollsMinted(_poll, _Poll.minted + _amount);
    c().setMinted(_poll, msgSender(), v().getMinted(_poll, msgSender()) + _amount);
    uint sqrt_amount = u().sqrt(_amount);
    uint sqrt_share = u().sqrt(v().total_share(v().getPair(_Poll.pool,_topic)));
    uint mintable = _amount * sqrt_amount / (sqrt_amount + sqrt_share);
    address _pool = v().getPoll(_poll).pool;
    address _pair = v().getPair(_pool, _topic);
    ITopic(_pair).mint(msgSender(), mintable);
    c().setClaimable(_pair, v().claimable(_pair) + (_amount - mintable));
  }
  
  function addPool (address _pool, string memory _name) public {
    require(IPool(_pool).owner() == msgSender(), "only pool owner can execute");
    require(bytes(v().pool_names(_pool)).length == 0, "pool is already registered");
    require(v().pool_addresses(_name) == address(0), "pool name is taken");
    ICollector(a().collector()).collect(msgSender());
    c().setPoolNames(_pool,_name);
    c().setPoolAddresses(_name, _pool);
    uint free_topic = v().free_topic();
    string memory topic_name = v().topic_names(free_topic);
    c().setPairs(IPool(_pool).token(), free_topic, IFactory(a().factory()).issue(topic_name, topic_name, address(a())));
  }
  
  function updatePollTopics(uint _poll, uint[] memory _topics) public {
    v().existsPoll(_poll);
    Poll memory p = v().getPoll(_poll);
    require(IPool(p.pool).owner() == msgSender(), "only pool owner can execute");
    c().setPollTopics(_poll, _topics);
    
  }
  
  function setPoll (address _pool, uint _amount, uint _blocks, uint[] memory _topics) public {
    v().existsPool(_pool);
    require(IPool(_pool).owner() == msgSender(), "only pool owner can execute");
    require(_amount <= IPool(_pool).available(), "pool amount not enough");
    c().setPolls(_pool, _amount, block.number + _blocks, _topics);
    IPool(_pool).setPoll(_amount);
  }
  
  function closePoll (uint _poll) public {
    v().existsPoll(_poll);
    Poll memory p = v().getPoll(_poll);
    require(IPool(p.pool).owner() == msgSender(), "only pool owner can execute");
    require(p.phase == 1, "poll already closed");
    c().setPollsMintable(_poll, p.amount - p.minted);
    if(p.block_until > block.number){
      c().setPollBlockUntil(_poll, block.number);
    }
    c().setPollsPhase(_poll, 2);
  }

  function closeClaim (uint _poll) public{
    v().existsPoll(_poll);
    Poll memory p = v().getPoll(_poll);
    require(IPool(p.pool).owner() == msgSender(), "only pool owner can execute");
    require(p.phase == 2, "claim period not open");
    address _pool = p.pool;
    address _pair = v().getPair(_pool, v().free_topic());
    c().setClaimable(_pair, v().claimable(_pair) + (p.amount - p.minted));
    c().setPollsMinted(_poll, 0);
    c().setPollsPhase(_poll, 3);
  }
  
  function _claim (uint _poll, uint _topic, uint _converted_amount, uint mintable, uint _amount) internal {
    Poll memory _Poll = v().getPoll(_poll);
    c().setVotes(_poll, msgSender(), v().getVote(_poll, msgSender()) + _amount);
    c().setTopicVotes(_poll, msgSender(), _topic, v().getVote(_poll, msgSender()) + _amount);
    c().setPollsTotalVotes(_poll, _Poll.total_votes + _amount);
    IPool(_Poll.pool).vote(msgSender(), _amount);
    address _pool = _Poll.pool;
    address _pair = v().getPair(_pool, _topic);
    ITopic(_pair).mint(msgSender(), mintable);
    c().setClaimable(_pair, v().claimable(_pair) + (_converted_amount - mintable));
  }
  
  function _setPair (address _pool, uint _topic) internal {
    if(v().getPair(_pool, _topic) == address(0)){
      string memory name = u().concat(u().concat(IERC20Metadata(IPool(_pool).token()).name(),"/"), v().topic_names(_topic));
      c().setPairs(IPool(_pool).token(), _topic, IFactory(a().factory()).issue(name, name, address(a())));
    }
  }
  
  function vote (uint _poll, uint _amount, uint _topic) public {
    v().existsPoll(_poll);
    v().existsTopic(_topic);
    Poll memory _Poll = v().getPoll(_poll);
    require(_Poll.block_until >= block.number, "poll is over");
    require(v().getTopicVote(_poll, msgSender(), _topic) == 0, "already voted");
    require(u().includes(_Poll.topics, _topic), "topic not votable");
    ICollector(a().collector()).collect(msgSender());
    _setPair(_Poll.pool, _topic);
    (uint mintable,  uint converted) = v().getMintable(_poll, _amount, _topic);
    c().setPollsMinted(_poll, _Poll.minted + converted);
    _claim(_poll, _topic, converted, mintable, _amount);
  }
  
}
