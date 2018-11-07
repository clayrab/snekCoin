pragma solidity ^0.4.10;

import "./LibInterface.sol";
import "./lib/Ownable.sol";
import "./SnekCoinBack.sol";

contract SnekCoinToken is Ownable {
  SnekCoinBack back;
  constructor(address addr) public {
    back = SnekCoinBack(addr);
  }

  // ****** BEGIN TEST FUNCTIONS ******
  function getSender()
  public constant returns(address){
    return back.getSender();
  }
  // ****** END TEST FUNCTIONS ******

  // ****** BEGIN BASIC FUNCTIONS ******
  function setRoot(address root)
  public onlyBy(owner, owner) returns(bool){
    return back.setRoot(root);
  }
  function getRoot()
  public view returns(address){
    return back.getRoot();
  }
  function setOwner(address owner)
  public onlyBy(owner, owner) returns(bool){
    return back.setOwner(owner);
  }
  function getOwner()
  public view returns(address){
    return back.getOwner();
  }
  // ****** END BASIC FUNCTIONS ******

  // ****** BEGIN CONTRACT BUSINESS FUNCTIONS ******
  function approveMine(address who, uint256 amount)
  public onlyBy(owner, owner) returns(bool) {
    return back.approveMine(who, amount);
  }
  function isMineApproved(address who)
  public view returns(uint256) {
    return back.isMineApproved(who);
  }

  function changeMiningPrice(uint256 amount)
  public onlyBy(owner, owner) returns(bool){
    return back.changeMiningPrice(amount);
  }
  function changeMiningSnekPrice(uint256 amount)
  public onlyBy(owner, owner) returns(bool){
    return back.changeMiningSnekPrice(amount);
  }

  function getMiningPrice()
  public view returns(uint256){
    return back.getMiningPrice();
  }
  function getMiningSnekPrice()
  public view returns(uint256){
    return back.getMiningSnekPrice();
  }

  function mine(uint256 amount)
  public payable returns(bool) {
    return back.mine(amount, msg.sender, msg.value);
  }
  function mineWithSnek(uint256 amount, uint256 payAmount)
  public returns(bool) {
    return back.mineWithSnek(amount, msg.sender, payAmount);
  }

  // ****** END CONTRACT BUSINESS FUNCTIONS ******

  // ****** BEGIN PAYABLE FUNCTIONS ******
  function() public payable {
    // accept random incoming payment
  }
  function withdraw(uint256 amountWei)
  onlyBy(owner, owner) public{
    if(address(this).balance > amountWei) {
      msg.sender.transfer(amountWei);
    }
  }
  function getBalance()
  public view returns (uint256) {
    return address(this).balance;
  }
  // ****** END PAYABLE FUNCTIONS ******

  // ****** BEGIN ERC20 ******
  function totalSupply() public view returns(uint256){
    return back.totalSupply();
  }
  function balanceOf(address tokenOwner) public view returns(uint256){
    return back.balanceOf(tokenOwner);
  }
  function allowance(address tokenOwner, address spender) public view returns(uint256){
    return back.allowance(tokenOwner, spender);
  }
  function transfer(address to, uint tokens) public returns(bool){
    return back.transfer(to, tokens, msg.sender);
  }
  function approve(address spender, uint tokens) public returns(bool){
    return back.approve(spender, tokens, msg.sender);
  }
  function transferFrom(address from, address to, uint tokens) public returns(bool){
    return back.transferFrom(from, to, tokens, msg.sender);
  }
  // ****** END ERC20 ******
}
