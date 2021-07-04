//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../core/UseConfig.sol";
import "../interfaces/IPool.sol";
import "../lib/EIP712MetaTransaction.sol";

contract Withdraw is Ownable, UseConfig, EIP712MetaTransaction {

  constructor(address _addr) UseConfig(_addr) EIP712MetaTransaction("Withdraw", "1") {}

  function withdraw(address _to, address _voter, uint _amount, address _token) external {
    v().onlyMarket(msg.sender);
    uint _reward = _amount * 80 / 100;
    IERC20(_token).transfer(_to, _reward);
    IERC20(_token).transfer(_voter, _amount - _reward);
  }
  
  function addFund (uint _poll, uint _amount) public {
    v().existsPoll(_poll);
    Poll memory p = v().getPoll(_poll);
    require(p.phase == 1, "poll already closed");
    IERC20(IPool(p.pool).token()).transferFrom(msgSender(), address(this), _amount);
    c().setPollAmount(_poll, p.amount + _amount);
  }

  function removeFund (uint _poll, uint _amount) public {
    v().existsPoll(_poll);
    Poll memory p = v().getPoll(_poll);
    require(p.phase == 1, "poll already closed");
    require(IPool(p.pool).owner() == msgSender(), "only pool owner can execute");
    uint mintable = p.amount - p.minted;
    require(mintable >= _amount, "amount too large");
    IERC20(IPool(p.pool).token()).transfer(msgSender(), _amount);
    c().setPollAmount(_poll, p.amount - _amount);
  }
  
}
