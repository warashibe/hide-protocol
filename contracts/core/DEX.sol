//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../lib/EIP712MetaTransaction.sol";
import "./UseConfig.sol";
import "../interfaces/ITopic.sol";
import "../interfaces/ICollector.sol";

contract DEX is Ownable, UseConfig, EIP712MetaTransaction {
  
  constructor(address _addr) UseConfig(_addr) EIP712MetaTransaction("DEX", "1"){}
  
  function convert (address _pair, uint _amount) public {
    uint _balance = v().balanceOf(_pair, msgSender());
    require(_amount <= _balance, "share not enough");
    uint _supply = v().totalSupply(_pair);
    uint _last_balance = v().share_sqrt(_pair, msgSender());
    uint _last_supply = v().total_share_sqrt(_pair);
    uint _new_balance = u().sqrt(_balance * _balance - _amount);
    uint diff = _last_balance - _new_balance;
    uint _totalSupply = _supply + _balance - diff - _last_balance;
    ICollector(a().collector()).collect(msgSender());
    uint mintable = v().getConvertibleAmount(_pair, diff, msgSender());
    ITopic(_pair).mint(msgSender(), mintable);
    m().setTotalShareSqrt(_pair, _totalSupply);
    m().setShareSqrt(_pair, msgSender(), _new_balance);
    m().setLastBlocks(_pair, msgSender(), block.number);
    m().setLastBlock(_pair, block.number);
    m().setLastSupply(_pair, _supply - diff);
    if(v().claimable(_pair) >= mintable){
      c().setClaimable(_pair, v().claimable(_pair) - mintable);
    }else{
      m().setClaimed(_pair, ITopic(_pair).totalInterests() - (mintable - v().claimable(_pair)));
      c().setClaimable(_pair, 0);
    }
    e().convert(_pair, _amount, msgSender(), mintable);
  }
  
}
