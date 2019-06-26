pragma solidity ^0.5.8;

import "./LibInterfaceExample.sol";

library ExampleVersion2 {
  function getUint(LibInterfaceExample.S storage s) public view returns (uint) {
    return s.i * 10;
  }

  function setUint(LibInterfaceExample.S storage s, uint i) public {
    s.i = i;
  }
}
