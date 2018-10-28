pragma solidity ^0.4.8;

import "./LibInterfaceExample.sol";

library ExampleReverts {
  function getUint(LibInterfaceExample.S storage s) public constant returns (uint) {
    revert();
    return s.i;
  }
  function setUint(LibInterfaceExample.S storage s, uint i) public {
    s.i = i;
  }
}
