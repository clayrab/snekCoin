pragma solidity ^0.4.10;

import "./LibInterface.sol";
import "./lib/Ownable.sol";
import "./SnekCoinStripper.sol";

contract SnekCoinToken is Ownable {
  SnekCoinStripper stripper;
  constructor(address addr) public {
    stripper = SnekCoinStripper(addr);
  }
  // ****** BEGIN PAYABLE FUNCTIONS ******
  function() public payable {
    // accept random incoming payment
  }
  function withdraw(uint256 amountWei)
  onlyBy(owner, owner) public{
    //if(address(this).balance > amountWei) {
      msg.sender.transfer(amountWei);
    //}
  }
  function getBalance()
  public view returns (uint256) {
    return address(this).balance;
  }
  // ****** END PAYABLE FUNCTIONS ******

  // ****** BEGIN BASIC FUNCTIONS ******
  function setRoot(address root)
  public returns(bool){
    return stripper.setRoot(root);
  }
  function getRoot()
  public view returns(address){
    return stripper.getRoot();
  }
  // ****** END BASIC FUNCTIONS ******

  // ****** BEGIN CONTRACT BUSINESS FUNCTIONS ******
  function mine(address who, uint256 amount, uint256 ethAmount)
  public payable returns(bool) {
    return stripper.mine(who, amount, ethAmount);
  }
  function changePrice(uint256 amount)
  public returns(bool){
    return stripper.changePrice(amount);
  }
  // ****** END CONTRACT BUSINESS FUNCTIONS ******

  // ****** BEGIN ERC20 ******
  function totalSupply() public constant returns(uint256){
    return stripper.totalSupply();
  }
  function balanceOf(address tokenOwner) public constant returns (uint256){
    return stripper.balanceOf(tokenOwner);
  }
  function allowance(address tokenOwner, address spender) public constant returns (uint256){
    return stripper.allowance(tokenOwner, spender);
  }
  function transfer(address to, uint tokens) public returns (bool){
    return stripper.transfer(to, tokens, msg.sender);
  }
  function approve(address spender, uint tokens) public returns (bool){
    return stripper.approve(spender, tokens, msg.sender);
  }
  function transferFrom(address from, address to, uint tokens) public returns (bool){
    return stripper.transferFrom(from, to, tokens, msg.sender);
  }
  // ****** END ERC20 ******
}
