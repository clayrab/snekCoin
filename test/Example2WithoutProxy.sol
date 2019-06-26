pragma solidity ^0.5.8;

contract Example2WithoutProxy {
  uint i;

  function getUint() public view returns (uint) {
    return i * 10;
  }

  function setUint(uint _i) public {
    i = _i;
  }
}
