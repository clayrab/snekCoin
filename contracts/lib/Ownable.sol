pragma solidity ^0.4.10;

contract Ownable {
  modifier onlyBy(address account1, address account2) {
    require(
      msg.sender == account1 || msg.sender == account2 ,
      "Sender not authorized."
    );
    _;
  }
  address public owner = msg.sender;
}
