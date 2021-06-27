//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP712MetaTransaction.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./interfaces/IPool.sol";
import "./interfaces/ICollector.sol";
import "./interfaces/ITopic.sol";
import "./interfaces/IFactory.sol";
import "./UseConfig.sol";

contract Governance is Ownable, UseConfig, EIP712MetaTransaction {
  
  constructor(address _config) UseConfig(_config) EIP712MetaTransaction("Governance", "1") {}

  function mint (uint _poll, uint _amount, uint _topic) public {
    c().existsPoll(_poll);
    c().existsTopic(_topic);
    Poll memory _Poll = c().getPoll(_poll);
    require (_Poll.phase == 2, "mint not allowed");
    uint _claimable = c().getClaimable(_poll, msgSender());
    require (_claimable >= _amount, "amount too big");
    ICollector(c().collector()).collect(msgSender());
    _setPair(_Poll.pool, _topic);
    c().setPollsMinted(_poll, _Poll.minted + _amount);
    c().setMinted(_poll, msgSender(), c().getMinted(_poll, msgSender()) + _amount);
    uint sqrt_amount = c().sqrt(_amount);
    uint sqrt_share = c().sqrt(c().total_share(c().pairs(_Poll.pool,_topic)));
    uint mintable = _amount * sqrt_amount / (sqrt_amount + sqrt_share);
    address _pool = c().getPoll(_poll).pool;
    address _pair = c().pairs(_pool, _topic);
    ITopic(_pair).mint(msgSender(), mintable);
    c().setClaimable(_pair, c().claimable(_pair) + (_amount - mintable));
  }
  
  function addPool (address _pool, string memory _name) public {
    require(IPool(_pool).owner() == msgSender(), "only pool owner can execute");
    require(bytes(c().pool_names(_pool)).length == 0, "pool is already registered");
    require(c().pool_addresses(_name) == address(0), "pool name is taken");
    ICollector(c().collector()).collect(msgSender());
    c().setPoolNames(_pool,_name);
    c().setPoolAddresses(_name, _pool);
    uint free_topic = c().free_topic();
    string memory topic_name = c().topic_names(free_topic);
    c().setPairs(_pool, free_topic, IFactory(c().factory()).issue(topic_name, topic_name, address(c())));
  }
  
  function updatePollTopics(uint _poll, uint[] memory _topics) public {
    c().existsPoll(_poll);
    Poll memory p = c().getPoll(_poll);
    require(IPool(p.pool).owner() == msgSender(), "only pool owner can execute");
    c().setPollTopics(_poll, _topics);
    
  }
  
  function setPoll (address _pool, uint _amount, uint _blocks, uint[] memory _topics) public {
    c().existsPool(_pool);
    require(IPool(_pool).owner() == msgSender(), "only pool owner can execute");
    require(_amount <= IPool(_pool).available(), "pool amount not enough");
    c().setPolls(_pool, _amount, block.number + _blocks, _topics);
    IPool(_pool).setPoll(_amount);
  }
  
  function closePoll (uint _poll) public {
    c().existsPoll(_poll);
    Poll memory p = c().getPoll(_poll);
    require(IPool(p.pool).owner() == msgSender(), "only pool owner can execute");
    require(p.phase == 1, "poll already closed");
    c().setPollsMintable(_poll, p.amount - p.minted);
    if(p.block_until > block.number){
      c().setPollBlockUntil(_poll, block.number);
    }
    c().setPollsPhase(_poll, 2);
  }

  function closeClaim (uint _poll) public{
    c().existsPoll(_poll);
    Poll memory p = c().getPoll(_poll);
    require(IPool(p.pool).owner() == msgSender(), "only pool owner can execute");
    require(p.phase == 2, "claim period not open");
    address _pool = p.pool;
    address _pair = c().pairs(_pool, c().free_topic());
    c().setClaimable(_pair, c().claimable(_pair) + (p.amount - p.minted));
    c().setPollsMinted(_poll, 0);
    c().setPollsPhase(_poll, 3);
  }
  
  function _claim (uint _poll, uint _topic, uint _converted_amount, uint mintable, uint _amount) internal {
    Poll memory _Poll = c().getPoll(_poll);
    c().setVotes(_poll, msgSender(), c().getVote(_poll, msgSender()) + _amount);
    c().setTopicVotes(_poll, msgSender(), _topic, c().getVote(_poll, msgSender()) + _amount);
    c().setPollsTotalVotes(_poll, _Poll.total_votes + _amount);
    IPool(_Poll.pool).vote(msgSender(), _amount);
    address _pool = _Poll.pool;
    address _pair = c().pairs(_pool, _topic);
    ITopic(_pair).mint(msgSender(), mintable);
    c().setClaimable(_pair, c().claimable(_pair) + (_converted_amount - mintable));
  }
  
  function _setPair (address _pool, uint _topic) internal {
    if(c().pairs(_pool, _topic) == address(0)){
      string memory name = c().concat(c().concat(IERC20Metadata(IPool(_pool).token()).name(),"/"),c().topic_names(_topic));
      c().setPairs(_pool, _topic, IFactory(c().factory()).issue(name, name, address(c())));
    }
  }
  
  function vote (uint _poll, uint _amount, uint _topic) public {
    c().existsPoll(_poll);
    c().existsTopic(_topic);
    Poll memory _Poll = c().getPoll(_poll);
    require(_Poll.block_until >= block.number, "poll is over");
    require(c().getTopicVote(_poll, msgSender(), _topic) == 0, "already voted");
    require(c().isVotable(_Poll.topics, _topic), "topic not votable");
    ICollector(c().collector()).collect(msgSender());
    _setPair(_Poll.pool, _topic);
    (uint mintable,  uint converted) = c().getMintable(_poll, _amount, _topic);
    c().setPollsMinted(_poll, _Poll.minted + converted);
    _claim(_poll, _topic, converted, mintable, _amount);
  }
  
}
