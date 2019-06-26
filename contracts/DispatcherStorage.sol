pragma solidity ^0.5.8;

//import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./lib/Ownable.sol";
//contract DispatcherStorage is Ownable {
contract DispatcherStorage is Ownable{

  address public lib;

  constructor(address newLib) public {
    replace(newLib);
  }

  function replace(address newLib) public onlyOwner /* onlyDAO */ {
    lib = newLib;
  }
}
