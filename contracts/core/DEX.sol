//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "../lib/EIP712MetaTransaction.sol";
import "./UseConfig.sol";
import "../interfaces/ITopic.sol";
import "../interfaces/ICollector.sol";
import "hardhat/console.sol";
contract DEX is Ownable, UseConfig, EIP712MetaTransaction {
  
  constructor(address _addr) UseConfig(_addr) EIP712MetaTransaction("DEX", "1"){}
  
  function convert (address _pair, uint _amount) public {
    uint _supply = v().totalSupply(_pair);
    uint share = v().toShare(_pair, _amount);
    if(share > v().shareOf(_pair, msgSender())) {
      _amount = v().toAmount(_pair, v().shareOf(_pair, msgSender()));
      share = v().toShare(_pair, _amount);
    }
    require(_amount > 0, "amount cannot be zero");
    ICollector(a().collector()).collect(msgSender());
    uint mintable = v().getConvertibleAmount(_pair, _amount, msgSender());

    ITopic(_pair).mint(msgSender(), mintable);
    m().setTotalShareSqrt(_pair, _supply - _amount);
    m().setTotalShare(_pair, v().total_share(_pair) - share);
    m().setShareSqrt(_pair, msgSender(), v().share_sqrt(_pair, msgSender()) - share);
    m().setLastBlocks(_pair, msgSender(), block.number);
    m().setLastBlock(_pair, block.number);
    if(v().claimable(_pair) >= mintable){
      c().setClaimable(_pair, v().claimable(_pair) - mintable);
    }else{
      m().setClaimed(_pair, ITopic(_pair).totalInterests() - (mintable - v().claimable(_pair)));
      c().setClaimable(_pair, 0);
    }
    e().convert(_pair, _amount, msgSender(), mintable);
  }
  
}
