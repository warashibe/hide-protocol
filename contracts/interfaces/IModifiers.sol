//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IModifiers {

  /* get contract addresses */
  
  function governance() external view returns(address);
  
  function market() external view returns(address);
  
  function collector() external view returns(address);
  
  function factory() external view returns(address);
  
  function dex() external view returns(address);
  
  function topics() external view returns(address);


  
  /* exists */
  function existsPool (address _pool) external view;
  
  function existsPoll (uint _poll) external view;
  
  function existsTopic (uint _topic) external view;


  /* modifiers */
  function onlyGovernanceOrDEX(address _sender) external view;

  function onlyGovernanceOrMarket(address _sender) external view;

  function onlyGovernanceOrWithdraw(address _sender) external view;
  
  function onlyGovernance(address _sender) external view;
  
  function onlyFactory(address _sender) external view;
  
  function onlyMarket(address _sender) external view;
  
  function onlyDEX(address _sender) external view;
  
  function onlyDEXOrMarket(address _sender) external view;
  
  function onlyFactoryOrGovernance(address _sender) external view;
  
}
