//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Set is AccessControlEnumerable, Ownable {
    bytes32 public constant EDITOR_ROLE = keccak256("EDITOR_ROLE");

    mapping(bytes32 => uint[]) uIntSet;
    mapping(bytes32 => string[]) stringSet;
    mapping(bytes32 => address[]) addressSet;
    mapping(bytes32 => bytes[]) bytesSet;
    mapping(bytes32 => bool[]) boolSet;
    mapping(bytes32 => int[]) intSet;

    mapping(bytes32 => mapping(uint => uint)) uIntMap;
    mapping(bytes32 => mapping(string => uint)) stringMap;
    mapping(bytes32 => mapping(address => uint)) addressMap;
    mapping(bytes32 => mapping(bytes => uint)) bytesMap;
    mapping(bytes32 => mapping(bool => uint)) boolMap;
    mapping(bytes32 => mapping(int => uint)) intMap;
    
    constructor() {
      _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
      _setupRole(EDITOR_ROLE, _msgSender());
    }
    
    modifier onlyEditor() {
      require(hasRole(EDITOR_ROLE,msg.sender), "only EDITOR can execute");
        _;
    }

    function addEditor(address _editor) public onlyOwner {
      grantRole(EDITOR_ROLE, _editor);
    }

    function removeEditor(address _editor) public onlyOwner {
      revokeRole(EDITOR_ROLE, _editor);
    }

    
    function getUintSet(bytes32 _key) external view returns(uint[] memory) {
        return uIntSet[_key];
    }
    
    function getUintSetAt(bytes32 _key, uint _i) external view returns(uint) {
        return uIntSet[_key][_i];
    }

    function pushUintSet(bytes32 _key, uint _uint) onlyEditor external {
      if(uIntMap[_key][_uint] == 0){
	uIntSet[_key].push(_uint);
	uIntMap[_key][_uint] = uIntSet[_key].length;
      }
    }

    function removeUintSet(bytes32 _key, uint _uint) onlyEditor external {
      if(uIntMap[_key][_uint] != 0){
	if(uIntMap[_key][_uint] != uIntSet[_key].length){
	  uIntSet[_key][uIntMap[_key][_uint] - 1] = uIntSet[_key][uIntSet[_key].length - 1];
	}
	uIntSet[_key].pop();
      }
      delete uIntMap[_key][_uint];
    }

    
    function getStringSet(bytes32 _key) external view returns(string[] memory) {
        return stringSet[_key];
    }
    
    function getStringSetAt(bytes32 _key, uint _i) external view returns(string memory) {
        return stringSet[_key][_i];
    }

    function pushStringSet(bytes32 _key, string memory _string) onlyEditor external {
      if(stringMap[_key][_string] == 0){
	stringSet[_key].push(_string);
	stringMap[_key][_string] = stringSet[_key].length;
      }
    }

    function removeStringSet(bytes32 _key, string memory _string) onlyEditor external {
      if(stringMap[_key][_string] != 0){
	if(stringMap[_key][_string] != stringSet[_key].length){
	  stringSet[_key][stringMap[_key][_string] - 1] = stringSet[_key][stringSet[_key].length - 1];
	}
	stringSet[_key].pop();
      }
    }


    function getAddressSet(bytes32 _key) external view returns(address[] memory) {
        return addressSet[_key];
    }
    
    function getAddressSetAt(bytes32 _key, uint _i) external view returns(address) {
        return addressSet[_key][_i];
    }

    function pushAddressSet(bytes32 _key, address _val) onlyEditor external {
      if(addressMap[_key][_val] == 0){
	addressSet[_key].push(_val);
	addressMap[_key][_val] = addressSet[_key].length;
      }
    }

    function removeAddressSet(bytes32 _key, address _val) onlyEditor external {
      if(addressMap[_key][_val] != 0){
	if(addressMap[_key][_val] != addressSet[_key].length){
	  addressSet[_key][addressMap[_key][_val] - 1] = addressSet[_key][addressSet[_key].length - 1];
	}
	addressSet[_key].pop();
      }
    }

    
    function getBytesSet(bytes32 _key) external view returns(bytes[] memory) {
        return bytesSet[_key];
    }
    
    function getBytesSetAt(bytes32 _key, uint _i) external view returns(bytes memory) {
        return bytesSet[_key][_i];
    }

    function pushBytesSet(bytes32 _key, bytes memory _bytes) onlyEditor external {
      if(bytesMap[_key][_bytes] == 0){
	bytesSet[_key].push(_bytes);
	bytesMap[_key][_bytes] = bytesSet[_key].length;
      }
    }

    function removeBytesSet(bytes32 _key, bytes memory _bytes) onlyEditor external {
      if(bytesMap[_key][_bytes] != 0){
	if(bytesMap[_key][_bytes] != bytesSet[_key].length){
	  bytesSet[_key][bytesMap[_key][_bytes] - 1] = bytesSet[_key][bytesSet[_key].length - 1];
	}
	bytesSet[_key].pop();
      }
    }

    
    function getBoolSet(bytes32 _key) external view returns(bool[] memory) {
        return boolSet[_key];
    }
    
    function getBoolSetAt(bytes32 _key, uint _i) external view returns(bool) {
        return boolSet[_key][_i];
    }

    function pushBoolSet(bytes32 _key, bool _val) onlyEditor external {
      if(boolMap[_key][_val] == 0){
	boolSet[_key].push(_val);
	boolMap[_key][_val] = boolSet[_key].length;
      }
    }

    function removeBoolSet(bytes32 _key, bool _val) onlyEditor external {
      if(boolMap[_key][_val] != 0){
	if(boolMap[_key][_val] != boolSet[_key].length){
	  boolSet[_key][boolMap[_key][_val] - 1] = boolSet[_key][boolSet[_key].length - 1];
	}
	boolSet[_key].pop();
      }
    }

    function getIntSet(bytes32 _key) external view returns(int[] memory) {
        return intSet[_key];
    }
    
    function getIntSetAt(bytes32 _key, uint _i) external view returns(int) {
        return intSet[_key][_i];
    }

    function pushIntSet(bytes32 _key, int _val) onlyEditor external {
      if(intMap[_key][_val] == 0){
	intSet[_key].push(_val);
	intMap[_key][_val] = intSet[_key].length;
      }
    }

    function removeIntSet(bytes32 _key, int _val) onlyEditor external {
      if(intMap[_key][_val] != 0){
	if(intMap[_key][_val] != intSet[_key].length){
	  intSet[_key][intMap[_key][_val] - 1] = intSet[_key][intSet[_key].length - 1];
	}
	intSet[_key].pop();
      }
    }
    
}
