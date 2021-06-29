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
    uint share_sqrt = v().share_sqrt(_pair, msgSender());
    require(_amount <= share_sqrt, "share not enough");
    ICollector(a().collector()).collect(msgSender());
    uint mintable = v().getConvertibleAmount(_pair, _amount, msgSender());
    ITopic(_pair).mint(msgSender(), mintable);
    uint new_share_sqrt = share_sqrt - _amount;
    uint new_share_square = new_share_sqrt * new_share_sqrt;
    uint diff = share_sqrt - new_share_sqrt;
    uint diff_square = v().share_sqrt(_pair, msgSender()) * v().share_sqrt(_pair, msgSender()) - new_share_square;

    c().setTotalShareSqrt(_pair, v().total_share_sqrt(_pair) - diff);
    c().setShareSqrt(_pair, msgSender(), share_sqrt - _amount);
    c().setShare(_pair, msgSender(), new_share_square);
    c().setTotalShare(_pair, v().total_share(_pair) - diff_square);
    if(v().claimable(_pair) >= mintable){
      c().setClaimable(_pair, v().claimable(_pair) - mintable);
    }else{
      c().setClaimed(_pair, ITopic(_pair).totalInterests() - (mintable - v().claimable(_pair)));
      c().setClaimable(_pair, 0);
    }
  }
  
}
