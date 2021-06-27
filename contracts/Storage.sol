//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Storage is AccessControlEnumerable, Ownable {
    bytes32 public constant EDITOR_ROLE = keccak256("EDITOR_ROLE");

    mapping(bytes32 => uint) uIntStorage;
    mapping(bytes32 => string) stringStorage;
    mapping(bytes32 => address) addressStorage;
    mapping(bytes32 => bytes) bytesStorage;
    mapping(bytes32 => bool) boolStorage;
    mapping(bytes32 => int) intStorage;
    
    mapping(bytes32 => uint[]) uIntArrayStorage;
    mapping(bytes32 => string[]) stringArrayStorage;
    mapping(bytes32 => address[]) addressArrayStorage;
    mapping(bytes32 => bytes[]) bytesArrayStorage;
    mapping(bytes32 => bool[]) boolArrayStorage;
    mapping(bytes32 => int[]) intArrayStorage;

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

    function getUint(bytes32 _key) external view returns(uint) {
        return uIntStorage[_key];
    }

    function getString(bytes32 _key) external view returns(string memory) {
        return stringStorage[_key];
    }

    function getAddress(bytes32 _key) external view returns(address) {
        return addressStorage[_key];
    }

    function getBytes(bytes32 _key) external view returns(bytes memory) {
        return bytesStorage[_key];
    }

    function getBool(bytes32 _key) external view returns(bool) {
        return boolStorage[_key];
    }

    function getInt(bytes32 _key) external view returns(int) {
        return intStorage[_key];
    }
    
    function getUintArray(bytes32 _key) external view returns(uint[] memory) {
        return uIntArrayStorage[_key];
    }

    function getStringArray(bytes32 _key) external view returns(string[] memory) {
        return stringArrayStorage[_key];
    }

    function getAddressArray(bytes32 _key) external view returns(address[] memory) {
        return addressArrayStorage[_key];
    }

    function getBytesArray(bytes32 _key) external view returns(bytes[] memory) {
        return bytesArrayStorage[_key];
    }

    function getBoolArray(bytes32 _key) external view returns(bool[] memory) {
        return boolArrayStorage[_key];
    }

    function getIntArray(bytes32 _key) external view returns(int[] memory) {
        return intArrayStorage[_key];
    }

    function setUint(bytes32 _key, uint _value) onlyEditor external {
        uIntStorage[_key] = _value;
    }

    function setString(bytes32 _key, string memory _value) onlyEditor external {
        stringStorage[_key] = _value;
    }

    function setAddress(bytes32 _key, address _value) onlyEditor external {
        addressStorage[_key] = _value;
    }

    function setBytes(bytes32 _key, bytes memory _value) onlyEditor external {
        bytesStorage[_key] = _value;
    }

    function setBool(bytes32 _key, bool _value) onlyEditor external {
        boolStorage[_key] = _value;
    }

    function setInt(bytes32 _key, int _value) onlyEditor external {
        intStorage[_key] = _value;
    }

    function setUintArray(bytes32 _key, uint[] memory _value) onlyEditor external {
        uIntArrayStorage[_key] = _value;
    }
    
    function setStringArray(bytes32 _key, string[] memory _value) onlyEditor external {
        stringArrayStorage[_key] = _value;
    }

    function setAddressArray(bytes32 _key, address[] memory _value) onlyEditor external {
        addressArrayStorage[_key] = _value;
    }

    function setBytesArray(bytes32 _key, bytes[] memory _value) onlyEditor external {
        bytesArrayStorage[_key] = _value;
    }

    function setBoolArray(bytes32 _key, bool[] memory _value) onlyEditor external {
        boolArrayStorage[_key] = _value;
    }

    function setIntArray(bytes32 _key, int[] memory _value) onlyEditor external {
        intArrayStorage[_key] = _value;
    }

    
    function deleteUint(bytes32 _key) onlyEditor external {
        delete uIntStorage[_key];
    }

    function deleteString(bytes32 _key) onlyEditor external {
        delete stringStorage[_key];
    }

    function deleteAddress(bytes32 _key) onlyEditor external {
        delete addressStorage[_key];
    }

    function deleteBytes(bytes32 _key) onlyEditor external {
        delete bytesStorage[_key];
    }

    function deleteBool(bytes32 _key) onlyEditor external {
        delete boolStorage[_key];
    }

    function deleteInt(bytes32 _key) onlyEditor external {
        delete intStorage[_key];
    }
    function deleteUintArray(bytes32 _key) onlyEditor external {
        delete uIntArrayStorage[_key];
    }

    function deleteStringArray(bytes32 _key) onlyEditor external {
        delete stringArrayStorage[_key];
    }

    function deleteAddressArray(bytes32 _key) onlyEditor external {
        delete addressArrayStorage[_key];
    }

    function deleteBytesArray(bytes32 _key) onlyEditor external {
        delete bytesArrayStorage[_key];
    }

    function deleteBoolArray(bytes32 _key) onlyEditor external {
        delete boolArrayStorage[_key];
    }

    function deleteIntArray(bytes32 _key) onlyEditor external {
        delete intArrayStorage[_key];
    }
    
}
