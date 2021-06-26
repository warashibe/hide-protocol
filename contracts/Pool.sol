//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Pool is Ownable {
  address public token;
  uint private _locked_amount;
  address public market;
  mapping(address => uint) used_vp;
  uint public total_used_vp;
  modifier onlyMarket {
    require(msg.sender == market, "only market can execute");
    _;
  }

  constructor(address _token, address _market) {
    token = _token;
    market = _market;
  }

  function getTotalVP () public view returns (uint _vp){
    _vp = 1000 * 10 ** 18 - total_used_vp;
  }

  function getVP (address _voter) public view returns (uint _vp){
    _vp = IERC20(token).balanceOf(_voter) - used_vp[_voter];
  }

  function available () public view returns (uint _amount){
    _amount = IERC20(token).balanceOf(address(this)) - _locked_amount;
  }

  function setPoll (uint _amount) public{
    _locked_amount += _amount;
  }

  function vote (address _voter, uint _amount) external{
    require(getVP(_voter) >= _amount, "VP not enough");
    used_vp[_voter] += _amount;
    total_used_vp += _amount;
  }
  function withdraw(address _to, address _voter, uint _amount) public onlyMarket{
    uint _reward = _amount * 80 / 100;
    IERC20(token).transfer(_to, _reward);
    IERC20(token).transfer(_voter, _amount - _reward);
  }
}
