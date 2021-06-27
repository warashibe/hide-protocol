//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Topic.sol";
import "./interfaces/INFT.sol";
import "./UseConfig.sol";
import "./interfaces/ICollector.sol";
import "./EIP712MetaTransaction.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Factory is Ownable, UseConfig, EIP712MetaTransaction {
  
  constructor(address _config) UseConfig(_config) EIP712MetaTransaction("Factory", "1") {}

  function _issue (string memory _name, string memory _sym, address _config) internal returns (address _token){
    Topic _topic = new Topic(_name, _sym, c().freigeld_numerator(), c().freigeld_denominator(), _config);
    _topic.transferOwnership(msgSender());
    return address(_topic);
  }
  
  function issue (string memory _name, string memory _sym, address _config) external returns (address _token){
    c().onlyGovernance(msgSender());
    return _issue(_name, _sym, _config);
  }

  function createFreeTopic (string memory _name, string memory _id) public onlyOwner{
    uint _topic = _createTopic(_name, _id);
    c().setFreeTopic(_topic);
  }
  
  function createTopic (string memory _name, string memory _id) public returns (uint _index) {
    ICollector(c().collector()).collect(msgSender());
    _index = _createTopic(_name, _id);
  }
  
  function _createTopic (string memory _name, string memory _id) internal returns (uint _index) {
    require(c().topic_indexes(_name) == 0, "topic name is taken");
    _index = INFT(c().topics()).mint(msgSender(), _id);
    c().setTopicNames(_index, _name);
    c().setTopicIndexes(_name, _index);
  }
}
