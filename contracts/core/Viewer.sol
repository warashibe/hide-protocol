//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/ITopic.sol";
import "../interfaces/IStorage.sol";
import "../interfaces/ISet.sol";
import "../interfaces/IVP.sol";
import "../interfaces/IUtils.sol";
import "../interfaces/IAddresses.sol";

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

contract Viewer {
  address private addr;
  /* constructor */
  
  constructor(address _addr) {
    addr = _addr;
  }
  
  /* pure utils */
  
  function sqrt(uint x) internal view returns (uint){
    return IUtils(IAddresses(addr).utils()).sqrt(x);
  }

  /* storage adaptors */
  
  function _getString(bytes memory _key) internal view returns(string memory){
    return IStorage(IAddresses(addr).store()).getString(keccak256(_key));
  }
  
  function _getAddress(bytes memory _key) internal view returns(address){
    return IStorage(IAddresses(addr).store()).getAddress(keccak256(_key));
  }
  
  function _getUint(bytes memory _key) internal view returns(uint){
    return IStorage(IAddresses(addr).store()).getUint(keccak256(_key));
  }

  function _getUintSet(bytes memory _key) internal view returns(uint[] memory){
    return ISet(IAddresses(addr).set()).getUintSet(keccak256(_key));
  }
  
  function _getUintSetAt(bytes memory _key, uint _i) internal view returns(uint){
    return ISet(IAddresses(addr).set()).getUintSetAt(keccak256(_key), _i);
  }
  
  function _getBool(bytes memory _key) internal view returns(bool){
    return IStorage(IAddresses(addr).store()).getBool(keccak256(_key));
  }

  function _getUintArray(bytes memory _key) internal view returns(uint[] memory){
    return IStorage(IAddresses(addr).store()).getUintArray(keccak256(_key));
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

  /* protocol parameters */

  function totalSupply(address pair) public view returns (uint256 _supply) {
    uint256 minus = dilution_denominator() == 0 ? 0 : total_share_sqrt(pair) * (block.number - lastBlock(pair)) * dilution_numerator() / dilution_denominator();
    _supply = lastSupply(pair) > minus ? lastSupply(pair) - minus : 0;
  }

  function balanceOf(address pair, address account) public view returns (uint _balance) {
    uint minus = dilution_denominator() == 0 ? 0 : share_sqrt(pair, account) * (block.number - lastBlocks(pair, account)) * dilution_numerator() / dilution_denominator();
    _balance =  share_sqrt(pair, account) > minus ? share_sqrt(pair, account) - minus : 0;
  }

  function lastBlock(address _addr) public view returns(uint) {
    return _getUint(abi.encode("lastBlock", _addr));
  }
  
  function lastSupply(address _addr) public view returns(uint) {
    return _getUint(abi.encode("lastSupply", _addr));
  }
  
  function lastBlocks(address _addr, address _addr2) public view returns(uint) {
    return _getUint(abi.encode("lastBlocks", _addr, _addr2));
  }
  
  function poll_topics(uint _uint) public view returns(uint[] memory) {
    return _getUintSet(abi.encode("poll_topics", _uint));
  }

  function poll_topic_votes(uint _uint, uint _topic) public view returns(uint) {
    return _getUint(abi.encode("poll_topic_votes", _uint, _topic));
  }
  
  function item_topics(address _addr, uint _uint) public view returns(uint[] memory) {
    return _getUintArray(abi.encode("item_topics", _addr, _uint));
  }
  
  function items(address _addr, uint _uint) public view returns(bool) {
    return _getBool(abi.encode("items", _addr, _uint));
  }

  function freigeld_numerator () public view returns (uint){
    return _getUint(abi.encode("freigeld_numerator"));
  }
  
  function freigeld_denominator () public view returns (uint){
    return _getUint(abi.encode("freigeld_denominator"));
  }

  function dilution_numerator () public view returns (uint){
    return _getUint(abi.encode("dilution_numerator"));
  }
  
  function dilution_denominator () public view returns (uint){
    return _getUint(abi.encode("dilution_denominator"));
  }
  
  function creator_percentage () public view returns (uint){
    return _getUint(abi.encode("creator_percentage"));
  }

  function poll_count () public view returns (uint){
    return _getUint(abi.encode("poll_count"));
  }

  function free_topic () public view returns (uint){
    return _getUint(abi.encode("free_topic"));
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
      topics: _getUintArray(abi.encode("polls", _uint, "topics")),
      token: _getAddress(abi.encode("polls", _uint, "token")) 
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

  function item_indexes(string memory _str) public view returns(address nft, uint id){
    id =_getUint(abi.encode("item_indexes_id",_str));
    nft = _getAddress(abi.encode("item_indexes_contract",_str));
  }
  
  function pairs(address _addr, uint _uint) public view returns(address){
    return _getAddress(abi.encode("pairs",_addr, _uint));
  }

  function pair_tokens(address _addr) public view returns(address){
    return _getAddress(abi.encode("pair_tokens",_addr));
  }

  function pair_topics(address _addr) public view returns(uint){
    return _getUint(abi.encode("pair_topics",_addr));
  }
  
  function kudos(address _addr1, address _addr2) public view returns(uint){
    return _getUint(abi.encode("kudos",_addr1, _addr2));
  }
  
  function total_kudos(address _addr) public view returns(uint){
    return _getUint(abi.encode("total_kudos",_addr));
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

  function getConvertibleAmount(address _pair, uint _amount, address _holder) public view returns(uint mintable){
    uint _share_sqrt = balanceOf(_pair, _holder);
    if(_amount > _share_sqrt){
      mintable = 0;
    }else{
      uint total_sqrt = totalSupply(_pair);
      uint claimable_amount = getConvertible(_pair);
      mintable = claimable_amount * _amount / total_sqrt;
    }
  }

  function getAvailable (uint _poll) public view returns (uint available){
    Poll memory _Poll = polls(_poll);
    available = _Poll.amount - _Poll.minted;
  }
  
  function getMintable (uint _poll, uint _amount, uint _topic) public view returns (uint mintable, uint converted){
    Poll memory p = polls(_poll);
    converted = getAvailable(_poll) * _amount / IVP(p.pool).getTotalVP();
    uint sqrt_amount = sqrt(converted);
    uint sqrt_share = total_share_sqrt(getPair(_poll, _topic));
    mintable = converted * sqrt_amount / (sqrt_amount + sqrt_share);
  }
  
  function getVote(uint _uint, address _addr) public view returns (uint) {
    return votes(_uint, _addr);
  }
  
  function getTopicVote(uint _uint1, address _addr, uint _uint2) public view returns (uint) {
    return topic_votes(_uint1, _addr, _uint2);
  }
  function getPair(uint _poll, uint _topic) public view returns (address _token) {
    _token = pairs(polls(_poll).token, _topic);
  }
  function getPool (string memory _name) public view returns (address _addr) {
    require(pool_addresses(_name) != address(0), "pool does not exist");
    _addr = pool_addresses(_name);
  }
  
  function getConvertible (address _pair) public view returns (uint _amount){
    _amount = ITopic(_pair).totalInterests() + claimable(_pair) - claimed(_pair);    
  }

  
  /* exists */
  function existsPool (address _pool) external view {
    require(bytes(pool_names(_pool)).length != 0, "pool does not exist");
  }
  
  function existsPoll (uint _poll) external view {
    require(polls(_poll).block_until != 0, "poll does not exist");
  }
  
  function existsTopic (uint _topic) external view {
    require(bytes(topic_names(_topic)).length != 0, "topic does not exist");
  }

  
  /* modifiers */
  
  function onlyDEXOrMarket(address _sender) public view {
    require(_sender == IAddresses(addr).dex() || _sender == IAddresses(addr).market(), "only DEX or market can execute");
  }

  function onlyGovernanceOrDEX(address _sender) public view {
    require(_sender == IAddresses(addr).governance() || _sender == IAddresses(addr).dex(), "only governance or DEX can execute");
  }
  
  function onlyGovernanceOrWithdraw(address _sender) public view {
    require(_sender == IAddresses(addr).governance() || _sender == IAddresses(addr).withdraw(), "only governance or withdraw can execute");
  }

  function onlyGovernance (address _sender) public view {
    require(_sender == IAddresses(addr).governance(), "only governance can execute");
  }

  function onlyFactory (address _sender) public view {
    require(_sender == IAddresses(addr).factory(), "only factory can execute");
  }

  function onlyFactoryOrGovernance (address _sender) public view {
    require(_sender == IAddresses(addr).factory() || _sender == IAddresses(addr).governance(), "only factory or governance can execute");
  }

  function onlyMarket (address _sender) public view {
    require(_sender == IAddresses(addr).market(), "only market can execute");
  }

  function onlyDEX (address _sender) public view {
    require(_sender == IAddresses(addr).dex(), "only DEX can execute");
  }
  
}
