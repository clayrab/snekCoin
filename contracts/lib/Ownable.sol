pragma solidity ^0.5.8;

contract Ownable {
  modifier onlyBy(address account1, address account2) {
    require(
      msg.sender == account1 || msg.sender == account2 ,
      "Sender not authorized."
    );
    _;
  }
  modifier onlyOwner() {
    require(msg.sender == owner, "Ownable: caller is not the owner");
    _;
  }
  address public owner = msg.sender;
  function changeOwner(address newOwner)
  public onlyBy(owner, owner) {
    owner = newOwner;
  }
}
