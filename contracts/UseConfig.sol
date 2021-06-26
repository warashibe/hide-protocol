pragma solidity ^0.8.0;

import "./interfaces/IConfig.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UseConfig is Ownable {
  address private _config;

  constructor(address _addr) public {
    _config = _addr;
  }

  function c() internal view returns (IConfig) {
    return IConfig(_config);
  }

  function configAddress() external view returns (address) {
    return _config;
  }
  
  function setAddress(address _addr) public onlyOwner {
    _config = _addr;
  }

}
