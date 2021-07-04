//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/ITopic.sol";
import "../interfaces/IStorage.sol";
import "../interfaces/ISet.sol";
import "../interfaces/IVP.sol";
import "../interfaces/IUtils.sol";
import "../interfaces/IViewer.sol";
import "../interfaces/IAddresses.sol";

contract Config is Ownable {

  address private addr;

  /* constructor */
  
  constructor(address _addr) {
    addr = _addr;
  }
  
  /* storage adaptors */

  function _pushUintSet(bytes memory _key, uint _uint) internal{
    return ISet(IAddresses(addr).set()).pushUintSet(keccak256(_key), _uint);
  }
  
  function _removeUintSet(bytes memory _key, uint _uint) internal{
    return ISet(IAddresses(addr).set()).removeUintSet(keccak256(_key), _uint);
  }
  
  function _setString(bytes memory _key, string memory _str) internal{
    return IStorage(IAddresses(addr).store()).setString(keccak256(_key), _str);
  }
  
  function _setAddress(bytes memory _key, address _addr) internal{
    return IStorage(IAddresses(addr).store()).setAddress(keccak256(_key), _addr);
  }
  
  function _setUint(bytes memory _key, uint _uint) internal{
    return IStorage(IAddresses(addr).store()).setUint(keccak256(_key), _uint);
  }
  
  function _setBool(bytes memory _key, bool _bool) internal{
    return IStorage(IAddresses(addr).store()).setBool(keccak256(_key), _bool);
  }
  
  function _setUintArray(bytes memory _key, uint[] memory _uints) internal{
    return IStorage(IAddresses(addr).store()).setUintArray(keccak256(_key), _uints);
  }

  function _deleteUintArray(bytes memory _key) internal{
    return IStorage(IAddresses(addr).store()).deleteUintArray(keccak256(_key));
  }
  
  /* protocol parameters */

  function setLastBlock(address _addr, uint _uint) external {
    return _setUint(abi.encode("lastBlock", _addr), _uint);
  }
  
  function setLastSupply(address _addr, uint _uint) external {
    return _setUint(abi.encode("lastSupply", _addr), _uint);
  }
  
  function setLastBlocks(address _addr, address _addr2, uint _uint) external {
    return _setUint(abi.encode("lastBlocks", _addr, _addr2), _uint);
  }
  
  function setDilutionRate(uint _numerator, uint _denominator) public onlyOwner {
    require(_numerator <= _denominator, "numerator must be less than or equal to denominator");
    _setUint(abi.encode("dilution_numerator"), _numerator);
    _setUint(abi.encode("dilution_denominator"), _denominator);
  }
  
  function setFreigeldRate(uint _numerator, uint _denominator) public onlyOwner {
    require(_numerator <= _denominator, "numerator must be less than or equal to denominator");
    _setUint(abi.encode("freigeld_numerator"), _numerator);
    _setUint(abi.encode("freigeld_denominator"), _denominator);
  }

  function setCreatorPercentage(uint _uint) public onlyOwner {
    require(_uint <= 10000, "creator_percentage must be less than or equal to 10000");
    _setUint(abi.encode("creator_percentage"),_uint);
  }

  function _setPollCount(uint _uint) internal {
    _setUint(abi.encode("poll_count"),_uint);
  }

  function setFreeTopic(uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyFactory(msg.sender);
    return _setUint(abi.encode("free_topic"),_uint);
  }

  /* protocol state setters */

  
  function pushPollTopics(uint _uint1, uint _uint2) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _pushUintSet(abi.encode("poll_topics", _uint1), _uint2);
  }
  
  function setPollTopicVotes(uint _uint1, uint _uint2, uint _uint3) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setUint(abi.encode("poll_topic_votes", _uint1, _uint2), _uint3);
  }

  function setItemTopics(address _addr, uint _uint, uint[] memory _uint_arr) external {
    IViewer(IAddresses(addr).viewer()).onlyMarket(msg.sender);
    _setUintArray(abi.encode("item_topics",_addr, _uint), _uint_arr);
  }

  function deleteItemTopics(address _addr, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyMarket(msg.sender);
    _deleteUintArray(abi.encode("item_topics",_addr, _uint));
  }
  
  function setItems(address _addr, uint _uint, bool _bool) external {
    IViewer(IAddresses(addr).viewer()).onlyMarket(msg.sender);
    _setBool(abi.encode("items",_addr, _uint), _bool);
  }
  
  function setPoolNames(address _addr, string memory _str) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setString(abi.encode("pool_names",_addr), _str);
  }
  
  function setPoolAddresses(string memory _str, address _addr) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setAddress(abi.encode("pool_addresses",_str), _addr);
  }  

  function setTopicNames(uint _uint, string memory _str) external {
    IViewer(IAddresses(addr).viewer()).onlyFactory(msg.sender);
    _setString(abi.encode("topic_names",_uint), _str);
  }  

  function setTopicIndexes(string memory _str, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyFactory(msg.sender);
    _setUint(abi.encode("topic_indexes",_str), _uint);
  }
  
  function setPairs(address _addr1, uint _uint, address _addr2) external {
    IViewer(IAddresses(addr).viewer()).onlyFactoryOrGovernance(msg.sender);
    _setAddress(abi.encode("pairs", _addr1, _uint), _addr2);
    _setAddress(abi.encode("pair_tokens", _addr2), _addr1);
    _setUint(abi.encode("pair_topics", _addr2), _uint);
  }
  
  function setTotalShareSqrt(address _addr, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("total_share_sqrt",_addr), _uint);
  }  

  function setClaimable(address _addr, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernanceOrDEX(msg.sender);
    _setUint(abi.encode("claimable",_addr), _uint);
  }
  
  function setClaimed(address _addr, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyDEX(msg.sender);
    _setUint(abi.encode("claimed",_addr), _uint);
  }  

  function setKudos(address _addr1, address _addr2, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("kudos",_addr1, _addr2), _uint);
  }

  function setTotalKudos(address _addr, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("total_kudos",_addr), _uint);
  }
  
  function setShare(address _addr1, address _addr2, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("share",_addr1, _addr2), _uint);
  }
  
  function setShareSqrt(address _addr1, address _addr2, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("share_sqrt",_addr1, _addr2), _uint);
  }

  function setPolls(address _pool, address _token, uint _amount, uint _block, uint[] memory _topics) external returns (uint _count) {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _count = IViewer(IAddresses(addr).viewer()).poll_count();
    _setUint(abi.encode("polls", _count, "phase"), 1);
    _setUint(abi.encode("polls", _count, "id"), _count);
    _setAddress(abi.encode("polls", _count, "pool"), _pool);
    _setAddress(abi.encode("polls", _count, "token"), _token);
    _setUint(abi.encode("polls", _count, "amount"), _amount);
    _setUint(abi.encode("polls", _count, "block_until"), _block);
    _setUintArray(abi.encode("polls", _count, "topics"), _topics);
    _setPollCount(_count + 1);
  }
  
  function setPollTopics(uint _poll, uint[] memory _topics) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setUintArray(abi.encode("polls", _poll, "topics"), _topics);
  }
  
  function setPollsMinted(uint _poll, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setUint(abi.encode("polls", _poll, "minted"), _uint);
  }
  
  function setPollBlockUntil(uint _poll, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setUint(abi.encode("polls", _poll, "block_until"), _uint);
  }
  
  function setPollsTotalVotes(uint _poll, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setUint(abi.encode("polls", _poll, "total_votes"), _uint);
  }
  
  function setPollsMintable(uint _poll, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setUint(abi.encode("polls", _poll, "mintable"), _uint);
  }
  
  function setPollAmount(uint _poll, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernanceOrWithdraw(msg.sender);
    _setUint(abi.encode("polls", _poll, "amount"), _uint);
  }
  
  function setPollsPhase(uint _poll, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setUint(abi.encode("polls", _poll, "phase"), _uint);
  }

  function setVotes(uint _uint1, address _addr, uint _uint2) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setUint(abi.encode("votes", _uint1, _addr), _uint2);
  }
  
  function setTopicVotes(uint _uint1, address _addr, uint _uint2, uint _uint3) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setUint(abi.encode("topic_votes", _uint1, _addr, _uint2), _uint3);
  }
  
  function setMinted(uint _uint1, address _addr, uint _uint2) external {
    IViewer(IAddresses(addr).viewer()).onlyGovernance(msg.sender);
    _setUint(abi.encode("minted", _uint1, _addr), _uint2);
  }

  function setItemIndexes(string memory _str, address _addr, uint _uint) external {
    IViewer(IAddresses(addr).viewer()).onlyMarket(msg.sender);
    _setUint(abi.encode("item_indexes_id", _str), _uint);
    _setAddress(abi.encode("item_indexes_contract", _str), _addr);
  }
  
}
