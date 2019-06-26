pragma solidity ^0.5.8;

import "./LibInterfaceExample.sol";
import "../contracts/lib/SafeMath.sol";

library Example {
  using SafeMath for uint;

  function getUint(LibInterfaceExample.S storage s) public view returns (uint) {
    return s.i;
  }
  function setUint(LibInterfaceExample.S storage s, uint i) public {
    s.i = i;
  }
}
