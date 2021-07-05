//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./UseConfig.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../lib/EIP712MetaTransaction.sol";
import "../interfaces/IVP.sol";
import "../interfaces/ICollector.sol";
import "../interfaces/ITopic.sol";
import "../interfaces/IFactory.sol";

contract Governance is Ownable, UseConfig, EIP712MetaTransaction {
  
  constructor(address _addr) UseConfig(_addr) EIP712MetaTransaction("Governance", "1") {}
  
  function addPool (address _pool, string memory _name) public {
    require(IVP(_pool).owner() == msgSender(), "only pool owner can execute");
    require(bytes(v().pool_names(_pool)).length == 0, "pool is already registered");
    require(v().pool_addresses(_name) == address(0), "pool name is taken");
    ICollector(a().collector()).collect(msgSender());
    c().setPoolNames(_pool,_name);
    c().setPoolAddresses(_name, _pool);
  }
  
  function updatePollTopics(uint _poll, uint[] memory _topics) public {
    mod().existsPoll(_poll);
    Poll memory p = v().polls(_poll);
    require(IVP(p.pool).owner() == msgSender(), "only pool owner can execute");
    c().setPollTopics(_poll, _topics);
    
  }
  
  function setPoll (address _pool, address _token, uint _amount, uint _blocks, uint[] memory _topics) public {
    mod().existsPool(_pool);
    require(IVP(_pool).owner() == msgSender(), "only pool owner can execute");
    IERC20Metadata(_token).transferFrom(msgSender(), a().withdraw(), _amount);
    uint _poll = c().setPolls(_pool, _token, _amount, block.number + _blocks, _topics);
    c().pushPollTopics(_poll, v().free_topic());
    uint free_topic = v().free_topic();
    if(v().getPair(_poll, free_topic) == address(0)){
      string memory topic_name = v().topic_names(free_topic);
      c().setPairs(_token, free_topic, IFactory(a().factory()).issue(topic_name, topic_name, address(a())));
    }

  }
  
  function closePoll (uint _poll) public {
    mod().existsPoll(_poll);
    Poll memory p = v().polls(_poll);
    require(IVP(p.pool).owner() == msgSender(), "only pool owner can execute");
    require(p.phase == 1, "poll already closed");
    uint mintable = p.amount - p.minted;
    c().setPollsMintable(_poll, mintable);
    if(p.block_until > block.number){
      c().setPollBlockUntil(_poll, block.number);
    }
    uint[] memory topics = v().poll_topics(_poll);
    uint minted = 0;
    for(uint i = 0; i < topics.length; i++){
      uint _minted = mintable * v().poll_topic_votes(_poll, topics[i]) / p.total_votes;
      if(i == topics.length - 1){
	_minted = mintable - minted;
      }
      address _pair = v().getPair(_poll, topics[i]);
      c().setClaimable(_pair, v().claimable(_pair) + _minted);
      minted += _minted;
    }
    c().setPollsMinted(_poll, p.amount);
    c().setPollsPhase(_poll, 2);
  }
  
  function _claim (uint _poll, uint _topic, uint _converted_amount, uint mintable, uint _amount) internal {
    Poll memory _Poll = v().polls(_poll);
    c().setVotes(_poll, msgSender(), v().getVote(_poll, msgSender()) + _amount);
    c().setTopicVotes(_poll, msgSender(), _topic, v().getVote(_poll, msgSender()) + _amount);
    c().setPollsTotalVotes(_poll, _Poll.total_votes + _amount);
    IVP(_Poll.pool).vote(msgSender(), _amount);
    address _pair = v().getPair(_poll, _topic);
    ITopic(_pair).mint(msgSender(), mintable);
    c().setClaimable(_pair, v().claimable(_pair) + (_converted_amount - mintable));
    c().pushUserPairs(msgSender(), _pair);
    c().pushTopicPairs(_topic, _pair);
    e().vote(_poll, _topic, _amount, msgSender(), _pair, mintable, _converted_amount - mintable);
  }
  
  function _setPair (address _token, uint _topic) internal {
    if(v().pairs(_token, _topic) == address(0)){
      string memory name = u().concat(u().concat(IERC20Metadata(_token).name(),"/"), v().topic_names(_topic));
      c().setPairs(_token, _topic, IFactory(a().factory()).issue(name, name, address(a())));
    }
  }
  
  function vote (uint _poll, uint _amount, uint _topic) public {
    mod().existsPoll(_poll);
    mod().existsTopic(_topic);
    Poll memory p = v().polls(_poll);
    require(p.block_until >= block.number, "poll is over");
    require(p.amount - p.minted > 0, "pool is empty");
    require(v().getTopicVote(_poll, msgSender(), _topic) == 0, "already voted");
    require(u().includes(p.topics, _topic), "topic not votable");
    ICollector(a().collector()).collect(msgSender());
    _setPair(p.token, _topic);
    (uint mintable,  uint converted) = v().getMintable(_poll, _amount, _topic);
    c().setPollTopicVotes(_poll, _topic, v().poll_topic_votes(_poll, _topic) + _amount);
    c().pushPollTopics(_poll, _topic);
    c().setPollsMinted(_poll, p.minted + converted);
    _claim(_poll, _topic, converted, mintable, _amount);
  }
  
}
