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
  // ****** END BASIC FUNCTIONS ******

  // ****** BEGIN CONTRACT BUSINESS FUNCTIONS ******
  function mine(uint256 amount)
  public payable returns(bool) {
    return back.mine(amount, msg.sender, msg.value);
  }
  function approveMine(address who, uint256 amount)
  public onlyBy(owner, owner) returns(bool) {
    //if(msg.value > )
    //return true;
    return back.approveMine(who, amount);
  }
  function isMineApproved(address who)
  public view returns(uint256) {
    return back.isMineApproved(who);
  }

  function mineWithSnek(address who, uint256 amount, uint256 ethAmount)
  public onlyBy(owner, owner) returns(bool) {

  }
  function changeMiningPrice(uint256 amount)
  public returns(bool){
    return back.changeMiningPrice(amount);
  }
  function getMiningPrice()
  public view returns(uint256){
    return back.getMiningPrice();
  }
  function changeSnekMiningPrice(uint256 amount)
  public returns(bool){

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
