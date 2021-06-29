//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Addresses is Ownable {

  address private _store;

  /* constructor */
  
  constructor(address _addr) {
    setStore(_addr);
  }
  
  /* storage adaptors */
  
  function _getAddress(bytes memory _key) internal view returns(address){
    return IStorage(_store).getAddress(keccak256(_key));
  }
  
  function _setAddress(bytes memory _key, address _addr) internal{
    return IStorage(_store).setAddress(keccak256(_key), _addr);
  }
  
  /* get contract addresses */

  function store() public view returns(address) {
    return _store;
  }
  
  function config() public view returns(address) {
    return _getAddress(abi.encode("config"));
  }
  
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

  function utils() public view returns(address) {
    return _getAddress(abi.encode("utils"));
  }

  function addresses() public view returns(address) {
    return address(this);
  }

  function viewer() public view returns(address) {
    return _getAddress(abi.encode("viewer"));
  }

  /* set contract addresses */

  function setConfig(address _addr) public onlyOwner {
    _setAddress(abi.encode("config"),_addr);
  }
  
  function setGovernance(address _addr) public onlyOwner {
    _setAddress(abi.encode("governance"),_addr);
  }
  
  function setTopics(address _addr) public onlyOwner {
    _setAddress(abi.encode("topics"),_addr);
  }
  
  function setMarket(address _addr) public onlyOwner {
    _setAddress(abi.encode("market"),_addr);
  }

  function setCollector(address _addr) public onlyOwner {
    _setAddress(abi.encode("collector"),_addr);
  }

  function setFactory(address _addr) public onlyOwner {
    _setAddress(abi.encode("factory"),_addr);
  }
  
  function setDEX(address _addr) public onlyOwner {
    _setAddress(abi.encode("dex"),_addr);
  }

  function setUtils(address _addr) public onlyOwner {
    _setAddress(abi.encode("utils"),_addr);
  }

  function setStore(address _addr) public onlyOwner {
    _store = _addr;
  }
  
  function setViewer(address _addr) public onlyOwner {
    _setAddress(abi.encode("viewer"),_addr);
  }  
  
}