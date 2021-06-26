//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "./EIP712MetaTransaction.sol";
import "./UseConfig.sol";
import "./interfaces/ITopic.sol";
import "./interfaces/ICollector.sol";

contract DEX is Ownable, UseConfig, EIP712MetaTransaction {
  
  constructor(address _config) UseConfig(_config) EIP712MetaTransaction("DEX", "1"){}
  
  function getConvertibleAmount(address _pair, uint _amount, address _holder) public view returns(uint mintable){
    uint share_sqrt = c().share_sqrt(_pair, _holder);
    if(_amount > share_sqrt){
      mintable = 0;
    }else{
      uint total_sqrt = c().total_share_sqrt(_pair);
      uint claimable_amount = c().getConvertible(_pair);
      mintable = claimable_amount * _amount / total_sqrt;
    }
  }
  function convert (address _pair, uint _amount) public {
    uint share_sqrt = c().share_sqrt(_pair, msgSender());
    require(_amount <= share_sqrt, "share not enough");
    ICollector(c().collector()).collect(msgSender());
    uint mintable = getConvertibleAmount(_pair, _amount, msgSender());
    ITopic(_pair).mint(msgSender(), mintable);
    uint new_share_sqrt = share_sqrt - _amount;
    uint new_share_square = new_share_sqrt * new_share_sqrt;
    uint diff = share_sqrt - new_share_sqrt;
    uint diff_square = c().share_sqrt(_pair, msgSender()) * c().share_sqrt(_pair, msgSender()) - new_share_square;

    c().setTotalShareSqrt(_pair, c().total_share_sqrt(_pair) - diff);
    c().setShareSqrt(_pair, msgSender(), share_sqrt - _amount);
    c().setShare(_pair, msgSender(), new_share_square);
    c().setTotalShare(_pair, c().total_share(_pair) - diff_square);
    if(c().claimable(_pair) >= mintable){
      c().setClaimable(_pair, c().claimable(_pair) - mintable);
    }else{
      c().setClaimed(_pair, ITopic(_pair).totalInterests() - (mintable - c().claimable(_pair)));
      c().setClaimable(_pair, 0);
    }
  }
  
}
