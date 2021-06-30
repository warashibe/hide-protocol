//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IConfig {

  function setItemTopics(address _addr, uint _uint, uint[] memory _uint_arr) external;

  function deleteItemTopics(address _addr, uint _uint) external;
  
  function setItems(address _addr, uint _uint, bool _bool) external;
  
  function setDEX(address _addr) external;
  
  function setCreatorPercentage(uint _uint) external;

  function setGovernance(address _addr) external;
  
  function setTopics(address _addr) external;
  
  function setFreeTopic(uint _uint) external;

  function setPoolNames(address _addr, string memory _str) external;
  
  function setPoolAddresses(string memory _str, address _addr) external;

  function setTopicNames(uint _uint, string memory _str) external;

  function setTopicIndexes(string memory _str, uint _uint) external;
  
  function setPairs(address _addr1, uint _uint, address _addr2) external;

  function setKudos(address _addr, address _addr2, uint _uint) external;
  
  function setTotalKudos(address _addr, uint _uint) external;
    
  function setTotalShare(address _addr, uint _uint) external;
  
  function setTotalShareSqrt(address _addr, uint _uint) external;

  function setClaimable(address _addr, uint _uint) external;
  
  function setClaimed(address _addr, uint _uint) external;

  function setShare(address _addr1, address _addr2, uint _uint) external;
  
  function setShareSqrt(address _addr1, address _addr2, uint _uint) external;

  function setMarket(address _addr) external;

  function setCollector(address _addr) external;

  function setFactory(address _addr) external;
  
  function setPolls(address _pool, uint _amount, uint _block, uint[] memory _topics) external;
  
  function setPollTopics(uint _poll, uint[] memory _topics) external;
  
  function setPollsMinted(uint _poll, uint _uint) external;
  
  function setPollBlockUntil(uint _poll, uint _uint) external;
  
  function setPollsTotalVotes(uint _poll, uint _uint) external;
  
  function setPollsMintable(uint _poll, uint _uint) external;
  
  function setPollsPhase(uint _poll, uint _uint) external;
  
  function setVotes(uint _uint1, address _addr, uint _uint2) external;
  
  function setTopicVotes(uint _uint1, address _addr, uint _uint2, uint _uint3) external;
  
  function setMinted(uint _uint1, address _addr, uint _uint2) external;
  
  function setItemIndexes(string memory _str, address _addr, uint _uint) external;
}
