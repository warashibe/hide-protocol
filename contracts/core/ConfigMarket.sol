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
import "../interfaces/IModifiers.sol";

contract ConfigMarket is Ownable {

  address private addr;

  /* constructor */
  
  constructor(address _addr) {
    addr = _addr;
  }
  
  /* storage adaptors */

  function _pushUintSet(bytes memory _key, uint _uint) internal{
    return ISet(IAddresses(addr).set()).pushUintSet(keccak256(_key), _uint);
  }

  function _pushAddressSet(bytes memory _key, address _addr) internal{
    return ISet(IAddresses(addr).set()).pushAddressSet(keccak256(_key), _addr);
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
  
  function setLastBlocks(address _addr, address _addr2, uint _uint) external {
    return _setUint(abi.encode("lastBlocks", _addr, _addr2), _uint);
  }
  
  function setDilutionRate(uint _numerator, uint _denominator) public onlyOwner {
    require(_numerator <= _denominator, "numerator must be less than or equal to denominator");
    _setUint(abi.encode("dilution_numerator"), _numerator);
    _setUint(abi.encode("dilution_denominator"), _denominator);
  }
  
  function setCreatorPercentage(uint _uint) public onlyOwner {
    require(_uint <= 10000, "creator_percentage must be less than or equal to 10000");
    _setUint(abi.encode("creator_percentage"),_uint);
  }
  
  function setBurnLimits(address _addr, uint _uint) external onlyOwner{
    _setUint(abi.encode("burn_limits",_addr), _uint);
  }

  /* protocol state setters */

  function pushItemPairs(address _addr1, uint _uint, address _addr2) external {
    IModifiers(IAddresses(addr).modifiers()).onlyGovernanceOrMarket(msg.sender);
    _pushAddressSet(abi.encode("item_pairs", _addr1, _uint), _addr2);
  }

  function setItemTopics(address _addr, uint _uint, uint[] memory _uint_arr) external {
    IModifiers(IAddresses(addr).modifiers()).onlyMarket(msg.sender);
    _setUintArray(abi.encode("item_topics",_addr, _uint), _uint_arr);
  }

  function deleteItemTopics(address _addr, uint _uint) external {
    IModifiers(IAddresses(addr).modifiers()).onlyMarket(msg.sender);
    _deleteUintArray(abi.encode("item_topics",_addr, _uint));
  }
  
  function setItems(address _addr, uint _uint, bool _bool) external {
    IModifiers(IAddresses(addr).modifiers()).onlyMarket(msg.sender);
    _setBool(abi.encode("items",_addr, _uint), _bool);
  }
  
  function setTotalShareSqrt(address _addr, uint _uint) external {
    IModifiers(IAddresses(addr).modifiers()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("total_share_sqrt",_addr), _uint);
  }  

  function setTotalShare(address _addr, uint _uint) external {
    IModifiers(IAddresses(addr).modifiers()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("total_share",_addr), _uint);
  }  
  
  function setGenesises(address _addr, uint _uint) external {
    IModifiers(IAddresses(addr).modifiers()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("genesises",_addr), _uint);
  }  
  
  function setClaimed(address _addr, uint _uint) external {
    IModifiers(IAddresses(addr).modifiers()).onlyDEX(msg.sender);
    _setUint(abi.encode("claimed",_addr), _uint);
  }  

  function setKudos(address _addr1, address _addr2, uint _uint) external {
    IModifiers(IAddresses(addr).modifiers()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("kudos",_addr1, _addr2), _uint);
  }

  function setTotalKudos(address _addr, uint _uint) external {
    IModifiers(IAddresses(addr).modifiers()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("total_kudos",_addr), _uint);
  }

  function setUserItemBurn(address _addr1, address _addr2, uint _uint1, address _addr3, uint _uint2) external{
    IModifiers(IAddresses(addr).modifiers()).onlyMarket(msg.sender);
    _setUint(abi.encode("user_item_burn",_addr1, _addr2, _uint1, _addr3), _uint2);
  }
  
  function setShare(address _addr1, address _addr2, uint _uint) external {
    IModifiers(IAddresses(addr).modifiers()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("share",_addr1, _addr2), _uint);
  }
  
  function setShareSqrt(address _addr1, address _addr2, uint _uint) external {
    IModifiers(IAddresses(addr).modifiers()).onlyDEXOrMarket(msg.sender);
    _setUint(abi.encode("share_sqrt",_addr1, _addr2), _uint);
  }

  function setItemIndexes(string memory _str, address _addr, uint _uint) external {
    IModifiers(IAddresses(addr).modifiers()).onlyMarket(msg.sender);
    _setUint(abi.encode("item_indexes_id", _str), _uint);
    _setAddress(abi.encode("item_indexes_contract", _str), _addr);
  }
  
}
