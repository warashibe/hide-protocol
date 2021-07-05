//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interfaces/IAddresses.sol";
import "../interfaces/IViewer.sol";

contract Modifiers {
  address private addr;
  /* constructor */
  
  constructor(address _addr) {
    addr = _addr;
  }

  /* exists */
  function existsPool (address _pool) external view {
    require(bytes(IViewer(IAddresses(addr).viewer()).pool_names(_pool)).length != 0, "pool does not exist");
  }
  
  function existsPoll (uint _poll) external view {
    require(IViewer(IAddresses(addr).viewer()).polls(_poll).block_until != 0, "poll does not exist");
  }
  
  function existsTopic (uint _topic) external view {
    require(bytes(IViewer(IAddresses(addr).viewer()).topic_names(_topic)).length != 0, "topic does not exist");
  }

  
  /* modifiers */
  
  function onlyDEXOrMarket(address _sender) public view {
    require(_sender == IAddresses(addr).dex() || _sender == IAddresses(addr).market(), "only DEX or market can execute");
  }

  function onlyGovernanceOrDEX(address _sender) public view {
    require(_sender == IAddresses(addr).governance() || _sender == IAddresses(addr).dex(), "only governance or DEX can execute");
  }

  function onlyGovernanceOrMarket(address _sender) public view {
    require(_sender == IAddresses(addr).governance() || _sender == IAddresses(addr).market(), "only governance or market can execute");
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
