pragma solidity ^0.4.10;

import "../contracts/LibInterface.sol";
import "../contracts/lib/SafeMath.sol";

library SnekCoin0_0_X {
  using SafeMath for uint;

  function totalSupply(LibInterface.S storage s)
  public constant returns (uint) {
    return s.totalSupp * 10;
  }
}
