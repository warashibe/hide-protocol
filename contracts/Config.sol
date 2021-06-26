//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ITopic.sol";
import "./Storage.sol";

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

contract Config is Ownable {

  address private _storage;

  
  /* modifiers */
  
  function onlyDEXOrMarket(address _sender) public view {
    require(_sender == dex() || _sender == market(), "only DEX or market can execute");
  }

  function onlyGovernanceOrDEX(address _sender) public view {
    require(_sender == governance() || _sender == dex(), "only governance or DEX can execute");
  }

  function onlyGovernance (address _sender) public view {
    require(_sender == governance(), "only governance can execute");
  }

  function onlyFactory (address _sender) public view {
    require(_sender == factory(), "only factory can execute");
  }

  function onlyFactoryOrGovernance (address _sender) public view {
    require(_sender == factory() || _sender == governance(), "only factory or governance can execute");
  }

  function onlyMarket (address _sender) public view {
    require(_sender == market(), "only market can execute");
  }

  function onlyDEX (address _sender) public view {
    require(_sender == dex(), "only DEX can execute");
  }

  
  /* constructor */
  
  constructor(address _addr) public {
    _storage = _addr;
  }

  
  /* pure utils */
  
  function concat( string memory a, string memory b) public pure returns(string memory) {
    return string(abi.encodePacked(a, b));
  }

  function isVotable (uint[] memory _topics, uint _topic) external pure returns(bool _votable){
    if(_topics.length == 0){
      _votable = true;
    }else{
      for(uint i = 0;i<_topics.length;i++){
	if(_topics[i] == _topic){
	  _votable = true;
	  break;
	}
      }
    }
  }
  
  function sqrt(uint x) public pure returns (uint){
    uint n = x / 2;
    uint lstX = 0;
    while (n != lstX){
      lstX = n;
      n = (n + x/n) / 2; 
    }
    return uint(n);
  }

  
  /* storage adaptors */
  
  function _getString(bytes memory _key) internal view returns(string memory){
    return Storage(_storage).getString(keccak256(_key));
  }
  
  function _setString(bytes memory _key, string memory _str) internal{
    return Storage(_storage).setString(keccak256(_key), _str);
  }
  
  function _getAddress(bytes memory _key) internal view returns(address){
    return Storage(_storage).getAddress(keccak256(_key));
  }
  
  function _setAddress(bytes memory _key, address _addr) internal{
    return Storage(_storage).setAddress(keccak256(_key), _addr);
  }
  
  function _getUint(bytes memory _key) internal view returns(uint){
    return Storage(_storage).getUint(keccak256(_key));
  }
  
  function _setUint(bytes memory _key, uint _uint) internal{
    return Storage(_storage).setUint(keccak256(_key), _uint);
  }
  
  function _getUintArray(bytes memory _key) internal view returns(uint[] memory){
    return Storage(_storage).getUintArray(keccak256(_key));
  }
  
  function _setUintArray(bytes memory _key, uint[] memory _uints) internal{
    return Storage(_storage).setUintArray(keccak256(_key), _uints);
  }


  /* get contract addresses */
  
  function governance() public view returns(address) {
    return _getAddress(abi.encode("governance"));
  }
  
  function market() public view returns(address) {
    return _getAddress(abi.encode("market"));
  }
  
  function collector() public view returns(address) {
    return _getAddress(abi.encode("collector"));
  }
  
  function factory() public view returns(address) {
    return _getAddress(abi.encode("factory"));
  }
  
  function dex() public view returns(address) {
    return _getAddress(abi.encode("dex"));
  }
  
  function topics() public view returns(address) {
    return _getAddress(abi.encode("topics"));
  }

  
  /* set contract addresses */
  
  function setGovernance(address _addr) public onlyOwner {
    _setAddress(abi.encode("governance"),_addr);
  }
  
  function setTopics(address _addr) public onlyOwner {
    _setAddress(abi.encode("topics"),_addr);
  }
  
  function setMarket(address _addr) external onlyOwner {
    _setAddress(abi.encode("market"),_addr);
  }

  function setCollector(address _addr) external onlyOwner {
    _setAddress(abi.encode("collector"),_addr);
  }

  function setFactory(address _addr) external onlyOwner {
    _setAddress(abi.encode("factory"),_addr);
  }
  
  function setDEX(address _addr) public onlyOwner {
    _setAddress(abi.encode("dex"),_addr);
  }

  
  /* protocol parameters */

  function freigeld_numerator () public view returns (uint){
    return _getUint(abi.encode("freigeld_numerator"));
  }
  
  function freigeld_denominator () public view returns (uint){
    return _getUint(abi.encode("freigeld_denominator"));
  }
  
  function setFreigeldRate(uint _numerator, uint _denominator) public onlyOwner {
    require(_numerator <= _denominator, "numerator must be less than or equal to denominator");
    _setUint(abi.encode("freigeld_numerator"), _numerator);
    _setUint(abi.encode("freigeld_denominator"), _denominator);
  }

  function creator_percentage () public view returns (uint){
    return _getUint(abi.encode("creator_percentage"));
  }

  function setCreatorPercentage(uint _uint) public onlyOwner {
    require(_uint <= 10000, "creator_percentage must be less than or equal to 10000");
    _setUint(abi.encode("creator_percentage"),_uint);
  }

  function poll_count () public view returns (uint){
    return _getUint(abi.encode("poll_count"));
  }

  function _setPollCount(uint _uint) internal {
    _setUint(abi.encode("poll_count"),_uint);
  }

  function free_topic () public view returns (uint){
    return _getUint(abi.encode("free_topic"));
  }
  
  function setFreeTopic(uint _uint) external {
    onlyFactory(msg.sender);
    return _setUint(abi.encode("free_topic"),_uint);
  }

  
  /* protocol state getters */
  
  function polls(uint _uint) public view returns(Poll memory){
    return Poll({
      phase:_getUint(abi.encode("polls", _uint, "phase")),
      id: _getUint(abi.encode("polls", _uint, "id")),
      pool: _getAddress(abi.encode("polls", _uint, "pool")),
      amount: _getUint(abi.encode("polls", _uint, "amount")),
      block_until: _getUint(abi.encode("polls", _uint, "block_until")),
      total_votes: _getUint(abi.encode("polls", _uint, "total_votes")),
      mintable: _getUint(abi.encode("polls", _uint, "mintable")),
      minted: _getUint(abi.encode("polls", _uint, "minted")),
      topics: _getUintArray(abi.encode("polls", _uint, "topics"))
    });
  }
  
  function pool_names(address _addr) public view returns(string memory){
    return _getString(abi.encode("pool_names",_addr));
  }

  function pool_addresses(string memory _str) public view returns(address){
    return _getAddress(abi.encode("pool_addresses",_str));
  }
  
  function topic_names(uint _uint) public view returns(string memory){
    return _getString(abi.encode("topic_names",_uint));
  }

  function topic_indexes(string memory _str) public view returns(uint){
    return _getUint(abi.encode("topic_indexes",_str));
  }

  function pairs(address _addr, uint _uint) public view returns(address){
    return _getAddress(abi.encode("pairs",_addr, _uint));
  }

  function kudos(address _addr1, address _addr2) public view returns(uint){
    return _getUint(abi.encode("kudos",_addr1, _addr2));
  }
  
  function total_kudos(address _addr) public view returns(uint){
    return _getUint(abi.encode("total_kudos",_addr));
  }
  
  function total_share(address _addr) public view returns(uint){
    return _getUint(abi.encode("total_share",_addr));
  }
  
  function total_share_sqrt(address _addr) public view returns(uint){
    return _getUint(abi.encode("total_share_sqrt",_addr));
  }
  
  function claimable(address _addr) public view returns(uint){
    return _getUint(abi.encode("claimable",_addr));
  }
  
  function claimed(address _addr) public view returns(uint){
    return _getUint(abi.encode("claimed",_addr));
  }
  
  function share(address _addr1, address _addr2) public view returns(uint){
    return _getUint(abi.encode("share",_addr1, _addr2));
  }
 
  function share_sqrt(address _addr1, address _addr2) public view returns(uint){
    return _getUint(abi.encode("share_sqrt",_addr1, _addr2));
  }

  function votes(uint _uint, address _addr) public view returns(uint){
    return _getUint(abi.encode("votes",_uint, _addr));
  }
  
  function topic_votes(uint _uint1, address _addr, uint _uint2) public view returns(uint){
    return _getUint(abi.encode("topic_votes",_uint1, _addr, _uint2));
  }

  function minted(uint _uint, address _addr) public view returns(uint){
    return _getUint(abi.encode("minted",_uint, _addr));
  }

  
  /* state aggrigators */

  function getPoll(uint _poll) public view returns (Poll memory) {
    return polls(_poll);
  }
  
  function getVote(uint _uint, address _addr) public view returns (uint) {
    return votes(_uint, _addr);
  }
  
  function getTopicVote(uint _uint1, address _addr, uint _uint2) public view returns (uint) {
    return topic_votes(_uint1, _addr, _uint2);
  }
  
  function getMinted(uint _uint, address _addr) public view returns (uint) {
    return minted(_uint, _addr);
  }  
  
  
  function getPair(address _pool, uint _topic) public view returns (address _token) {
    _token = pairs(_pool, _topic);
    require(_token != address(0), "pair does not exist");
  }
  
  function getClaimable (uint _poll, address _voter) public view returns (uint _amount){
    if(getPoll(_poll).block_until == 0){
      _amount = 0;
    }else{
      Poll memory p = getPoll(_poll);
      _amount = (p.mintable * getVote(_poll, _voter) / p.total_votes) - getMinted(_poll, _voter);
    }
  }

  function getPool (string memory _name) public view returns (address _addr) {
    require(pool_addresses(_name) != address(0), "pool does not exist");
    _addr = pool_addresses(_name);
  }
  
  function getConvertible (address _pair) public view returns (uint _amount){
    _amount = ITopic(_pair).totalInterests() + claimable(_pair) - claimed(_pair);    
  }
  

  /* protocol state setters */
  
  function setPoolNames(address _addr, string memory _str) external {
    onlyGovernance(msg.sender);
    _setString(abi.encode("pool_names",_addr), _str);
  }
  
  function setPoolAddresses(string memory _str, address _addr) external {
    onlyGovernance(msg.sender);
    _setAddress(abi.encode("pool_addresses",_str), _addr);
  }  

  function setTopicNames(uint _uint, string memory _str) external {
    onlyFactory(msg.sender);
    _setString(abi.encode("topic_names",_uint), _str);
  }  

  function setTopicIndexes(string memory _str, uint _uint) external {
    onlyFactory(msg.sender);
    _setUint(abi.encode("topic_indexes",_str), _uint);
  }
  
  function setPairs(address _addr1, uint _uint, address _addr2) external {
    onlyFactoryOrGovernance(msg.sender);
    _setAddress(abi.encode("pairs",_addr1, _uint), _addr2);
  }
  
  function setTotalShare(address _addr, uint _uint) external {
    onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("total_share",_addr), _uint);
  }
  
  function setTotalShareSqrt(address _addr, uint _uint) external {
    onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("total_share_sqrt",_addr), _uint);
  }  

  function setClaimable(address _addr, uint _uint) external {
    onlyGovernanceOrDEX(msg.sender);
    _setUint(abi.encode("claimable",_addr), _uint);
  }
  
  function setClaimed(address _addr, uint _uint) external {
    onlyDEX(msg.sender);
    _setUint(abi.encode("claimed",_addr), _uint);
  }  

  function setKudos(address _addr1, address _addr2, uint _uint) external {
    onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("kudos",_addr1, _addr2), _uint);
  }

  function setTotalKudos(address _addr, uint _uint) external {
    onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("total_kudos",_addr), _uint);
  }
  
  function setShare(address _addr1, address _addr2, uint _uint) external {
    onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("share",_addr1, _addr2), _uint);
  }
  
  function setShareSqrt(address _addr1, address _addr2, uint _uint) external {
    onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("share_sqrt",_addr1, _addr2), _uint);
  }

  function setPolls(address _pool, uint _amount, uint _block, uint[] memory _topics) external {
    onlyGovernance(msg.sender);
    uint _uint = poll_count();
    _setUint(abi.encode("polls", _uint, "phase"), 1);
    _setUint(abi.encode("polls", _uint, "id"), _uint);
    _setAddress(abi.encode("polls", _uint, "pool"), _pool);
    _setUint(abi.encode("polls", _uint, "amount"), _amount);
    _setUint(abi.encode("polls", _uint, "block_until"), _block);
    _setUintArray(abi.encode("polls", _uint, "topics"), _topics);
    _setPollCount(poll_count() + 1);
  }
  
  function setPollTopics(uint _poll, uint[] memory _topics) external {
    onlyGovernance(msg.sender);
    _setUintArray(abi.encode("polls", _poll, "topics"), _topics);
  }
  
  function setPollsMinted(uint _poll, uint _uint) external {
    onlyGovernance(msg.sender);
    _setUint(abi.encode("polls", _poll, "minted"), _uint);
  }
  
  function setPollBlockUntil(uint _poll, uint _uint) external {
    onlyGovernance(msg.sender);
    _setUint(abi.encode("polls", _poll, "block_until"), _uint);
  }
  
  function setPollsTotalVotes(uint _poll, uint _uint) external {
    onlyGovernance(msg.sender);
    _setUint(abi.encode("polls", _poll, "total_votes"), _uint);
  }
  
  function setPollsMintable(uint _poll, uint _uint) external {
    onlyGovernance(msg.sender);
    _setUint(abi.encode("polls", _poll, "mintable"), _uint);
  }
  
  function setPollsPhase(uint _poll, uint _uint) external {
    onlyGovernance(msg.sender);
    _setUint(abi.encode("polls", _poll, "phase"), _uint);
  }

  function setVotes(uint _uint1, address _addr, uint _uint2) external {
    onlyGovernance(msg.sender);
    _setUint(abi.encode("votes", _uint1, _addr), _uint2);
  }
  
  function setTopicVotes(uint _uint1, address _addr, uint _uint2, uint _uint3) external {
    onlyGovernance(msg.sender);
    _setUint(abi.encode("topic_votes", _uint1, _addr, _uint2), _uint3);
  }
  
  function setMinted(uint _uint1, address _addr, uint _uint2) external {
    onlyGovernance(msg.sender);
    _setUint(abi.encode("minted", _uint1, _addr), _uint2);
  }

  /* exists */
  function existsPool (address _pool) external {
    require(bytes(pool_names(_pool)).length != 0, "pool does not exist");
  }
  
  function existsPoll (uint _poll) external {
    require(getPoll(_poll).block_until != 0, "poll does not exist");
  }
  
  function existsTopic (uint _topic) external {
    require(bytes(topic_names(_topic)).length != 0, "topic does not exist");
  }
  
}
