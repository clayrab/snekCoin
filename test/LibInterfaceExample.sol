pragma solidity ^0.4.10;

library LibInterfaceExample {
  struct S {
    uint i;
    uint256 totalSupp;
    bytes32 name;
    uint8 decimals;
    uint creationTime;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
  }
  //uint public libCreationTime = now;
  function getUint(S storage s) public constant returns (uint256);
  function setUint(S storage s, uint i) public;
}
