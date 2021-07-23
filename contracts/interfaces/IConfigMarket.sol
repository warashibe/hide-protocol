//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IConfigMarket {

  function pushItemPairs(address _addr1, uint _uint, address _addr2) external;
    
  function setLastBlock(address _addr, uint _uint) external;
  
  function setLastBlocks(address _addr, address _addr2, uint _uint) external;

  function setDilutionRate(uint _numerator, uint _denominator) external;
  
  function setBurnLimits(address _addr, uint _uint) external;
  
  function setItemTopics(address _addr, uint _uint, uint[] memory _uint_arr) external;

  function deleteItemTopics(address _addr, uint _uint) external;
  
  function setItems(address _addr, uint _uint, bool _bool) external;
  
  function setDEX(address _addr) external;
  
  function setCreatorPercentage(uint _uint) external;

  function setKudos(address _addr, address _addr2, uint _uint) external;
  
  function setTotalKudos(address _addr, uint _uint) external;
    
  function setTotalShareSqrt(address _addr, uint _uint) external;

  function setTotalShare(address _addr, uint _uint) external;
  
  function setGenesises(address _addr, uint _uint) external;
  
  function setClaimed(address _addr, uint _uint) external;

  function setShare(address _addr1, address _addr2, uint _uint) external;
  
  function setShareSqrt(address _addr1, address _addr2, uint _uint) external;

  function setItemIndexes(string memory _str, address _addr, uint _uint) external;

  function setUserItemBurn(address _addr1, address _addr2, uint _uint1, address _addr3, uint _uint2) external;
}
