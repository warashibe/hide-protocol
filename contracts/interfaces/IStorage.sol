//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStorage  {
  function getUint(bytes32 _key) external view returns(uint);

  function getString(bytes32 _key) external view returns(string memory);

  function getAddress(bytes32 _key) external view returns(address);

  function getBool(bytes32 _key) external view returns(bool);

  function getUintArray(bytes32 _key) external view returns(uint[] memory);

  function setUint(bytes32 _key, uint _value) external;

  function setString(bytes32 _key, string memory _value) external;

  function setAddress(bytes32 _key, address _value) external;

  function setBool(bytes32 _key, bool _value) external;

  function setUintArray(bytes32 _key, uint[] memory _value) external;

  function deleteUintArray(bytes32 _key) external;
    
}
