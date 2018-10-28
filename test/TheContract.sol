pragma solidity ^0.4.10;

import "./LibInterfaceExample.sol";

contract TheContract {
  LibInterfaceExample.S s;

  using LibInterfaceExample for LibInterfaceExample.S;

  function get() public constant returns (uint) {
    return s.getUint();
  }

  function set(uint i) public {
    return s.setUint(i);
  }

}
