//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAddresses {

  /* get contract addresses */

  function config() external view returns(address);
  
  function governance() external view returns(address);
  
  function market() external view returns(address);

  function events() external view returns(address);
  
  function withdraw() external view returns(address);
  
  function collector() external view returns(address);
  
  function factory() external view returns(address);
  
  function dex() external view returns(address);
  
  function topics() external view returns(address);

  function utils() external view returns(address);

  function addresses() external view returns(address);

  function store() external view returns(address);

  function set() external view returns(address);

  function viewer() external view returns(address);
  
  /* set contract addresses */

  function setConfig(address _addr) external;
  
  function setGovernance(address _addr) external;

  function setEvents(address _addr) external;
  
  function setTopics(address _addr) external;
  
  function setMarket(address _addr) external;

  function setWithdraw(address _addr) external;

  function setCollector(address _addr) external;

  function setFactory(address _addr) external;
  
  function setDEX(address _addr) external;

  function setUtils(address _addr) external;

  function setStore(address _addr) external;

  function setViewer(address _addr) external;
  
}
