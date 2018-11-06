pragma solidity ^0.4.10;

import "./LibInterface.sol";
import "./lib/Ownable.sol";
//import "./PayableLib.sol";

// Just strips msg.value so lib can be called.
contract SnekCoinBack is Ownable {
  LibInterface.S public s;
  using LibInterface for LibInterface.S;
  //using snekCurrentVersion for address;
  constructor(bytes32 nm, uint8 dec, uint256 ts) public {
    s.name = nm;
    s.decimals = dec;
    s.totalSupp = ts;
    s.balances[msg.sender] = ts;
    s.root = address(this);
    s.weiPriceToMine = 1000000000000; // 0.000001 ETH
  }

  // ****** BEGIN TEST FUNCTIONS ******
  function getSender()
  public constant returns(address){
    return msg.sender;
  }
  // ****** END TEST FUNCTIONS ******

  // ****** BEGIN BASIC FUNCTIONS ******
  function setRoot(address root)
  public onlyBy(owner, s.root) returns(bool){
    s.root = root;
  }
  function getRoot()
  public view returns(address){
    return s.root;
  }
  // ****** END BASIC FUNCTIONS ******

  // ****** BEGIN CONTRACT BUSINESS FUNCTIONS ******

  function mine(uint256 amount, address sender, uint256 value)
  public onlyBy(s.root, s.root) returns(bool) {
    return s.mine(amount, sender, value);
  }
  function approveMine(address who, uint256 amount)
  public onlyBy(s.root, s.root) returns(bool) {
    return s.approveMine(who, amount);
  }
  function isMineApproved(address who)
  public view returns(uint256) {
    return s.isMineApproved(who);
  }

  function requestMineWithSnek(address who, uint256 amount, address sender)
  public payable returns(bool) {

  }
  function mineWithSnek(address who, uint256 amount, uint256 ethAmount)
  public onlyBy(owner, owner) returns(bool) {

  }
  function changeMiningPrice(uint256 amount)
  public returns(bool){
    return s.changeMiningPrice(amount);
  }
  function getMiningPrice()
  public view returns(uint256){
    return s.getMiningPrice();
  }
  function changeSnekMiningPrice(uint256 amount)
  public returns(bool){

  }
  // ****** END CONTRACT BUSINESS FUNCTIONS ******

  // ****** BEGIN ERC20 ******
  function totalSupply() public view returns(uint256){
    return s.totalSupply();
  }
  function balanceOf(address tokenOwner) public view returns(uint256){
    return s.balanceOf(tokenOwner);
  }
  function allowance(address tokenOwner, address spender) public view returns(uint256){
    return s.allowance(tokenOwner, spender);
  }
  function transfer(address to, uint tokens, address sender) public returns(bool){
    return s.transfer(to, tokens, sender);
  }
  function approve(address spender, uint tokens, address sender) public returns(bool){
    return s.approve(spender, tokens, sender);
  }
  function transferFrom(address from, address to, uint tokens, address sender) public returns(bool){
    return s.transferFrom(from, to, tokens, sender);
  }
  // ****** END ERC20 ******
}
