pragma solidity ^0.4.10;

import "./LibInterface.sol";
import "./lib/Ownable.sol";
//import "./PayableLib.sol";

// Just strips msg.value so lib can be called.
contract SnekCoinStripper is Ownable {
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
  function getSender()
  public constant returns(address){
    return msg.sender;
  }
  function mine(address who, uint256 amount, uint256 ethAmount)
  public onlyBy(s.root, s.root) returns(bool) {
    return s.mine(who, amount, ethAmount);
  }
  function changePrice(uint256 amount)
  public onlyBy(s.root, s.root) returns(bool){
    return s.changePrice(amount);
  }
  // ****** END CONTRACT BUSINESS FUNCTIONS ******

  // ****** BEGIN ERC20 ******
  function totalSupply()
  public constant onlyBy(s.root, s.root) returns(uint256){
    return s.totalSupply();
  }
  function balanceOf(address tokenOwner)
  public constant onlyBy(s.root, s.root) returns(uint256){
    return s.balanceOf(tokenOwner);
  }
  function allowance(address tokenOwner, address spender)
  public constant onlyBy(s.root, s.root) returns(uint256){
    return s.allowance(tokenOwner, spender);
  }
  function transfer(address to, uint tokens, address sender)
  public constant onlyBy(s.root, s.root) returns(bool){
    return s.transfer(to, tokens, sender);
  }
  function approve(address spender, uint tokens, address sender)
  public constant onlyBy(s.root, s.root) returns(bool){
    return s.approve(spender, tokens, sender);
  }
  function transferFrom(address from, address to, uint tokens, address sender)
  public constant onlyBy(s.root, s.root) returns(bool){
    return s.transferFrom(from, to, tokens, sender);
  }
  // ****** END ERC20 ******
}
