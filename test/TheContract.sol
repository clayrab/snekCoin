pragma solidity ^0.5.8;

import "./LibInterfaceExample.sol";

contract TheContract {
  LibInterfaceExample.S s;

  using LibInterfaceExample for LibInterfaceExample.S;

  function get() public view returns (uint) {
    return s.getUint();
  }

  function set(uint i) public {
    return s.setUint(i);
  }

}
