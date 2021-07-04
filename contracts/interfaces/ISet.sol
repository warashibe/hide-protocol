//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISet {
  
  function addEditor(address _editor) external;

  function removeEditor(address _editor) external;

    
  function getUintSet(bytes32 _key) external view returns(uint[] memory);
    
  function getUintSetAt(bytes32 _key, uint _i) external view returns(uint);

  function pushUintSet(bytes32 _key, uint _uint) external;

  function removeUintSet(bytes32 _key, uint _uint) external;

    
  function getStringSet(bytes32 _key) external view returns(string[] memory);
    
  function getStringSetAt(bytes32 _key, uint _i) external view returns(string memory);

  function pushStringSet(bytes32 _key, string memory _string) external;

  function removeStringSet(bytes32 _key, string memory _string) external;


  function getAddressSet(bytes32 _key) external view returns(address[] memory);
    
  function getAddressSetAt(bytes32 _key, uint _i) external view returns(address);

  function pushAddressSet(bytes32 _key, address _val) external;

  function removeAddressSet(bytes32 _key, address _val) external;

    
  function getBytesSet(bytes32 _key) external view returns(bytes[] memory);
    
  function getBytesSetAt(bytes32 _key, uint _i) external view returns(bytes memory);

  function pushBytesSet(bytes32 _key, bytes memory _bytes) external;

  function removeBytesSet(bytes32 _key, bytes memory _bytes) external;

    
  function getBoolSet(bytes32 _key) external view returns(bool[] memory);
    
  function getBoolSetAt(bytes32 _key, uint _i) external view returns(bool);

  function pushBoolSet(bytes32 _key, bool _val) external;

  function removeBoolSet(bytes32 _key, bool _val) external;
  

  function getIntSet(bytes32 _key) external view returns(int[] memory);
    
  function getIntSetAt(bytes32 _key, uint _i) external view returns(int);

  function pushIntSet(bytes32 _key, int _val) external;

  function removeIntSet(bytes32 _key, int _val) external;
    
}
