//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Topic.sol";
import "./UseConfig.sol";
import "../interfaces/INFT.sol";
import "../interfaces/ICollector.sol";
import "../lib/EIP712MetaTransaction.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Factory is Ownable, UseConfig, EIP712MetaTransaction {
  
  constructor(address _addr) UseConfig(_addr) EIP712MetaTransaction("Factory", "1") {}

  function _issue (string memory _name, string memory _sym, address _addr) internal returns (address _token){
    Topic _topic = new Topic(_name, _sym, v().freigeld_numerator(), v().freigeld_denominator(), _addr);
    return address(_topic);
  }
  
  function issue (string memory _name, string memory _sym, address _addr) external returns (address _token){
    mod().onlyGovernance(msgSender());
    return _issue(_name, _sym, _addr);
  }

  function createFreeTopic (string memory _name, string memory _id, string memory _ref) public onlyOwner{
    uint _topic = _createTopic(_name, _id, _ref);
    c().setFreeTopic(_topic);
  }
  
  function createTopic (string memory _name, string memory _id, string memory _ref) public returns (uint _index) {
    ICollector(a().collector()).collect(msgSender());
    _index = _createTopic(_name, _id, _ref);
  }
  
  function _createTopic (string memory _name, string memory _id, string memory _ref) internal returns (uint _index) {
    require(v().topic_indexes(_name) == 0, "topic name is taken");
    _index = INFT(a().topics()).mint(msgSender(), _id);
    c().setTopicNames(_index, _name);
    c().setTopicIndexes(_name, _index);
    e().createTopic(msgSender(), _name, _id, _ref);
  }
}
