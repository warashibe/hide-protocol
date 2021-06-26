//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../Collector.sol";

contract Agent {
  address collector;
  constructor(address _collector) {
    collector = _collector;
  }

  function test() public {
    Collector(collector).collect(msg.sender);
  }

}
