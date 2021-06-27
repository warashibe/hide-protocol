//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Poll {
  uint id;
  address pool;
  uint block_until;
  uint amount;
  uint minted;
  uint total_votes;
  uint mintable;
  uint phase;
  uint [] topics;
}

  interface IConfig {

  function governance() external view returns (address);
  function market() external view returns (address);
  function collector() external view returns (address);
  function factory() external view returns (address);
  function dex() external view returns (address);
  function topics() external view returns (address);
  function poll_count() external view returns (uint);
  function free_topic() external view returns (uint);
  function creator_percentage() external view returns (uint);
  function freigeld_numerator() external view returns (uint);
  function freigeld_denominator() external view returns (uint);

  function pool_names(address) external view returns (string memory);
  function pool_addresses(string memory) external view returns (address);  
  function topic_names(uint) external view returns (string memory);
  function topic_indexes(string memory) external view returns (uint);
  function total_share(address) external view returns (uint);
  function total_share_sqrt(address) external view returns (uint);  
  function claimable(address) external view returns (uint);
  function claimed(address) external view returns (uint);  
  function share(address, address) external view returns (uint);
  function kudos(address, address) external view returns (uint);
  function total_kudos(address) external view returns (uint);
  function share_sqrt(address, address) external view returns (uint);
  function pairs(address, uint) external view returns (address);
  function votes(uint, address) external view returns (uint);
  function topic_votes(uint, address, uint) external view returns (uint);
  function minted(uint, address) external view returns (uint);
  
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
  
  function getPoll(uint _poll) external view returns (Poll memory);
  
  function getVote(uint _uint1, address _addr) external view returns (uint);
  
  function getTopicVote(uint _uint1, address _addr, uint _uint2) external view returns (uint);
  
  function getMinted(uint _uint1, address _addr) external view returns (uint);
  
  function setVotes(uint _uint1, address _addr, uint _uint2) external;
  
  function setTopicVotes(uint _uint1, address _addr, uint _uint2, uint _uint3) external;
  
  function setMinted(uint _uint1, address _addr, uint _uint2) external;
  
  function getPair(address _pool, uint _topic) external view returns (address _token);
  
  function getClaimable (uint _poll, address _voter) external view returns (uint _amount);

  function getPool (string memory _name) external view returns (address _addr);
  
  function concat( string memory a, string memory b) external pure returns(string memory);

  function sqrt(uint x) external pure returns (uint);

  function getConvertible (address _pair) external view returns (uint _amount);
  
  function isVotable (uint[] memory _topics, uint _topic) external pure returns(bool _votable);
  
  function existsPool(address _pool) external;

  function existsTopic(uint _index) external;

  function existsPoll(uint _poll) external;

  function onlyGovernanceOrDEX(address _sender) external view;
  function onlyGovernance(address _sender) external view;
  function onlyFactory(address _sender) external view;
  function onlyMarket(address _sender) external view;
  function onlyDEX(address _sender) external view;
  function onlyDEXOrMarket(address _sender) external view;
  function onlyFactoryOrGovernance(address _sender) external view;
  
  function getMintable (uint _poll, uint _amount, uint _topic) external view returns (uint, uint);
  function getConvertibleAmount(address _pair, uint _amount, address _holder) external view returns(uint);
  
}
