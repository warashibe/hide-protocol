//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IConfig {

  function setPollTopicVotes(uint _uint1, uint _uint2, uint _uint3) external;
  
  function pushTopicPairs(uint _uint, address _addr) external;
  
  function pushUserPairs(address _addr1, address _addr2) external;
  
  function pushPollTopics(uint _uint1, uint _uint2) external;
  
  function setFreeTopic(uint _uint) external;

  function setPoolNames(address _addr, string memory _str) external;
  
  function setPoolAddresses(string memory _str, address _addr) external;

  function setTopicNames(uint _uint, string memory _str) external;

  function setTopicIndexes(string memory _str, uint _uint) external;
  
  function setPairs(address _addr1, uint _uint, address _addr2) external;

  function setClaimable(address _addr, uint _uint) external;
  
  function setPolls(address _pool, address _token, uint _amount, uint _block, uint[] memory _topics) external returns (uint);
  
  function setPollAmount(uint _poll, uint _uint) external;
  
  function setPollTopics(uint _poll, uint[] memory _topics) external;
  
  function setPollsMinted(uint _poll, uint _uint) external;
  
  function setPollBlockUntil(uint _poll, uint _uint) external;
  
  function setPollsTotalVotes(uint _poll, uint _uint) external;
  
  function setPollsMintable(uint _poll, uint _uint) external;
  
  function setPollsPhase(uint _poll, uint _uint) external;
  
  function setVotes(uint _uint1, address _addr, uint _uint2) external;
  
  function setTopicVotes(uint _uint1, address _addr, uint _uint2, uint _uint3) external;
  
  function setMinted(uint _uint1, address _addr, uint _uint2) external;
  
}
