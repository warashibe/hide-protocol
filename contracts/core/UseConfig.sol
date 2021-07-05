//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IConfig.sol";
import "../interfaces/IConfigMarket.sol";
import "../interfaces/IUtils.sol";
import "../interfaces/IViewer.sol";
import "../interfaces/IAddresses.sol";
import "../interfaces/IEvents.sol";
import "../interfaces/IModifiers.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UseConfig is Ownable {
  address private _addresses;

  constructor(address _addr) {
    _addresses = _addr;
  }

  function c() internal view returns (IConfig) {
    return IConfig(IAddresses(_addresses).config());
  }

  function m() internal view returns (IConfigMarket) {
    return IConfigMarket(IAddresses(_addresses).config_market());
  }

  function mod() internal view returns (IModifiers) {
    return IModifiers(IAddresses(_addresses).modifiers());
  }

  function v() internal view returns (IViewer) {
    return IViewer(IAddresses(_addresses).viewer());
  }
  
  function u() internal view returns (IUtils) {
    return IUtils(IAddresses(_addresses).utils());
  }

  function a() internal view returns (IAddresses) {
    return IAddresses(_addresses);
  }

  function e() internal view returns (IEvents) {
    return IEvents(IAddresses(_addresses).events());
  }
  
  function addresses() external view returns (address) {
    return _addresses;
  }
}
