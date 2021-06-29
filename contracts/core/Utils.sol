//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Utils {

  /* constructor */
  
  constructor() {}
  
  /* pure utils */
  
  function concat( string memory a, string memory b) public pure returns(string memory) {
    return string(abi.encodePacked(a, b));
  }

  function includes (uint[] memory _arr, uint _item) external pure returns(bool _included){
    if(_arr.length == 0){
      _included = true;
    }else{
      for(uint i = 0;i<_arr.length;i++){
	if(_arr[i] == _item){
	  _included = true;
	  break;
	}
      }
    }
  }
  
  function sqrt(uint x) public pure returns (uint){
    uint n = x / 2;
    uint lstX = 0;
    while (n != lstX){
      lstX = n;
      n = (n + x/n) / 2; 
    }
    return uint(n);
  }
  
}
