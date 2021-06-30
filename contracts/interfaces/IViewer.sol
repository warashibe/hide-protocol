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

interface IViewer {

  /* get contract addresses */
  
  function governance() external view returns(address);
  
  function market() external view returns(address);
  
  function collector() external view returns(address);
  
  function factory() external view returns(address);
  
  function dex() external view returns(address);
  
  function topics() external view returns(address);

  /* protocol parameters */

  function item_topics(address _addr, uint _uint) external view returns(uint[] memory);
  
  function items(address _addr, uint _uint) external view returns(bool);

  function item_indexes(string memory _str) external view returns(address, uint);
  
  function freigeld_numerator () external view returns (uint);
  
  function freigeld_denominator () external view returns (uint);
  
  function creator_percentage () external view returns (uint);

  function poll_count () external view returns (uint);

  function free_topic () external view returns (uint);
  
  /* protocol state getters */
  
  function polls(uint _uint) external view returns(Poll memory);
  
  function pool_names(address _addr) external view returns(string memory);

  function pool_addresses(string memory _str) external view returns(address);
  
  function topic_names(uint _uint) external view returns(string memory);

  function topic_indexes(string memory _str) external view returns(uint);

  function pairs(address _addr, uint _uint) external view returns(address);

  function kudos(address _addr1, address _addr2) external view returns(uint);
  
  function total_kudos(address _addr) external view returns(uint);
  
  function total_share(address _addr) external view returns(uint);
  
  function total_share_sqrt(address _addr) external view returns(uint);
  
  function claimable(address _addr) external view returns(uint);
  
  function claimed(address _addr) external view returns(uint);
  
  function share(address _addr1, address _addr2) external view returns(uint);
 
  function share_sqrt(address _addr1, address _addr2) external view returns(uint);

  function votes(uint _uint, address _addr) external view returns(uint);
  
  function topic_votes(uint _uint1, address _addr, uint _uint2) external view returns(uint);

  function minted(uint _uint, address _addr) external view returns(uint);

  
  /* state aggrigators */

  function getConvertibleAmount(address _pair, uint _amount, address _holder) external view returns(uint mintable);
  
  function getMintable (uint _poll, uint _amount, uint _topic) external view returns (uint mintable, uint converted);
  
  function getPoll(uint _poll) external view returns (Poll memory);
  
  function getVote(uint _uint, address _addr) external view returns (uint);
  
  function getTopicVote(uint _uint1, address _addr, uint _uint2) external view returns (uint);
  
  function getMinted(uint _uint, address _addr) external view returns (uint);
  
  
  function getPair(address _pool, uint _topic) external view returns (address _token);
  
  function getClaimable (uint _poll, address _voter) external view returns (uint _amount);

  function getPool (string memory _name) external view returns (address _addr);
  
  function getConvertible (address _pair) external view returns (uint _amount);

  
  /* exists */
  function existsPool (address _pool) external view;
  
  function existsPoll (uint _poll) external view;
  
  function existsTopic (uint _topic) external view;

  /* modifiers */
  function onlyGovernanceOrDEX(address _sender) external view;
  
  function onlyGovernance(address _sender) external view;
  
  function onlyFactory(address _sender) external view;
  
  function onlyMarket(address _sender) external view;
  
  function onlyDEX(address _sender) external view;
  
  function onlyDEXOrMarket(address _sender) external view;
  
  function onlyFactoryOrGovernance(address _sender) external view;
  
}
