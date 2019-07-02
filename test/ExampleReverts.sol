pragma solidity ^0.5.8;

import "./LibInterfaceExample.sol";

library ExampleReverts {
  function getUint(LibInterfaceExample.S storage s) public view returns (uint) {
    if(true){ // silences compiler warning.
      revert();
    }
    return s.i;
  }
  function setUint(LibInterfaceExample.S storage s, uint i) public {
    s.i = i;
  }
}
