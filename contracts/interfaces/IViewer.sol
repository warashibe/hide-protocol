//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Poll {
  uint id;
  address pool;
  address token;
  uint block_until;
  uint amount;
  uint minted;
  uint total_votes;
  uint mintable;
  uint phase;
  uint [] topics;
}

interface IViewer {

  /* protocol parameters */

  function burn_limits(address _addr) external view returns (uint);
  
  function totalSupply(address pair) external view returns (uint);
  
  function balanceOf(address pair, address account) external view returns (uint);
    
  function lastBlock() external view returns(uint);
  
  function lastSupply() external view returns(uint);
  
  function lastBlocks(address _addr) external view returns(uint);

  function poll_topic_votes(uint _uint, uint _topic) external view returns(uint);
  
  function poll_topics(uint _uint) external view returns(uint[] memory);
  
  function item_topics(address _addr, uint _uint) external view returns(uint[] memory);
  
  function items(address _addr, uint _uint) external view returns(bool);

  function item_indexes(string memory _str) external view returns(address, uint);

  function dilution_numerator () external view returns (uint);
  
  function dilution_denominator () external view returns (uint);
  
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
  
  function pair_tokens(address _addr) external view returns(address);

  function user_pairs(address _addr) external view returns(address[] memory);

  function topic_pairs(uint _uint) external view returns(address[] memory);

  function item_pairs(address _addr, uint _uint) external view returns(address[] memory);

  function pair_topics(address _addr) external view returns(uint);

  function kudos(address _addr1, address _addr2) external view returns(uint);
  
  function total_kudos(address _addr) external view returns(uint);
  
  function total_share_sqrt(address _addr) external view returns(uint);

  function total_share(address _addr) external view returns(uint);

  function token_version(address _addr) external view returns(uint);

  function genesises(address _addr) external view returns(uint);
  
  function claimable(address _addr) external view returns(uint);
  
  function claimed(address _addr) external view returns(uint);
  
  function share(address _addr1, address _addr2) external view returns(uint);
 
  function share_sqrt(address _addr1, address _addr2) external view returns(uint);

  function votes(uint _uint, address _addr) external view returns(uint);
  
  function topic_votes(uint _uint1, address _addr, uint _uint2) external view returns(uint);

  function minted(uint _uint, address _addr) external view returns(uint);

  
  /* state aggrigators */

  function getConvertibleAmount(address _pair, uint _amount, address _holder) external view returns(uint);

  function getAvailable (uint _poll) external view returns (uint);
  
  function getMintable (uint _poll, uint _amount, uint _topic) external view returns (uint mintable, uint converted);
  
  function getVote(uint _uint, address _addr) external view returns (uint);
  
  function getTopicVote(uint _uint1, address _addr, uint _uint2) external view returns (uint);
  
  function getPair(uint _poll, uint _topic) external view returns (address);
  
  function getPool (string memory _name) external view returns (address);
  
  function getConvertible (address _pair) external view returns (uint);

  function user_item_burn(address _addr1, address _addr2, uint _uint1, address _addr3) external view returns(uint);

  function toShare(address _pair, uint256 amount) external view returns (uint256 _share);
  
  function toAmount(address _pair, uint256 _share) external view returns (uint256 _amount);
  
  function shareOf(address _pair, address account) external view returns (uint256 _share);
}
