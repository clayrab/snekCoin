pragma solidity ^0.5.8;

import "./LibInterface.sol";
import "./lib/Ownable.sol";
import "./SnekCoinBack.sol";

contract SnekCoinToken is Ownable {
  SnekCoinBack back;
  constructor(address addr) public {
    back = SnekCoinBack(addr);
  }

  // ****** BEGIN TEST FUNCTIONS ******
  function getTokenSender()
  public view returns(address){
    return msg.sender;
  }
  function getBackSender()
  public view returns(address){
    return back.getBackSender();
  }
  function getSender()
  public view returns(address){
    return back.getSender();
  }
  // ****** END TEST FUNCTIONS ******

  // ****** BEGIN BASIC FUNCTIONS ******
  event SetRoot(address sender, address root);
  function setRoot(address root)
  public onlyBy(owner, owner) returns(bool){
    bool ret = back.setRoot(root);
    emit SetRoot(msg.sender, root);
    return ret;
  }

  function getRoot()
  public view returns(address){
    return back.getRoot();
  }
  event SetOwner(address sender, address owner);
  function setOwner(address owner)
  public onlyBy(owner, owner) returns(bool){
    bool ret = back.setOwner(owner);
    emit SetOwner(msg.sender, owner);
    return ret;
  }
  function getOwner()
  public view returns(address){
    return back.getOwner();
  }
  // ****** END BASIC FUNCTIONS ******

  // ****** BEGIN CONTRACT BUSINESS FUNCTIONS ******
  event ChangeMiningPrice(address sender, uint256 amount);
  function changeMiningPrice(uint256 amount)
  public onlyBy(owner, owner) returns(bool){
    bool ret = back.changeMiningPrice(amount);
    emit ChangeMiningPrice(msg.sender, amount);
    return ret;
  }
  event ChangeMiningSnekPrice(address sender, uint256 amount);
  function changeMiningSnekPrice(uint256 amount)
  public onlyBy(owner, owner) returns(bool){
    bool ret = back.changeMiningSnekPrice(amount);
    emit ChangeMiningSnekPrice(msg.sender, amount);
    return ret;
  }
  event ChangeEggPrice(address sender, uint256 amount);
  function changeEggPrice(uint256 amount)
  public onlyBy(owner, owner) returns(bool){
    bool ret = back.changeEggPrice(amount);
    emit ChangeEggPrice(msg.sender, amount);
    return ret;
  }

  function getMiningPrice()
  public view returns(uint256){
    return back.getMiningPrice();
  }
  function getMiningSnekPrice()
  public view returns(uint256){
    return back.getMiningSnekPrice();
  }
  function getEggPrice()
  public view returns(uint256){
    return back.getEggPrice();
  }
  function getMiningRate()
  public view returns(uint256){
    return back.getMiningRate();
  }
  event Mine(bytes32 signedMessage, address indexed sender, uint256 amount);
  function mine(bytes32 signedMessage, uint8 sigV, bytes32 sigR, bytes32 sigS, uint256 howManyEggs)
  public payable returns(uint256) {
    uint256 amount = back.mine(signedMessage, sigV, sigR, sigS, msg.sender, msg.value, howManyEggs);
    emit Mine(signedMessage, msg.sender, msg.value);
    emit Transfer(0x0000000000000000000000000000000000000000, msg.sender, amount);
    return amount;
  }
  // event MineWithSnek(bytes32 signedMessage, address indexed sender, uint256 amount);
  // function mineWithSnek(bytes32 signedMessage, uint8 sigV, bytes32 sigR, bytes32 sigS, uint256 payAmount)
  // public returns(uint256) {
  //   uint256 amount = back.mineWithSnek(signedMessage, sigV, sigR, sigS, msg.sender, payAmount);
  //   emit MineWithSnek(signedMessage, msg.sender, payAmount);
  //   emit Transfer(0x0000000000000000000000000000000000000000, msg.sender, amount);
  //   return amount;
  // }

  // event MineForUser(address indexed sender, uint256 amount);
  // function mineForUser(address user, uint256 amount)
  // public onlyBy(owner, owner) returns(uint256) {
  //   emit MineForUser(user, amount);
  //   return back.mineForUser(user, amount);
  // }
  function getUserNonce(address who)
  public view returns(uint32) {
    return back.getUserNonce(who);
  }
  // ****** END CONTRACT BUSINESS FUNCTIONS ******

  // ****** BEGIN PAYABLE FUNCTIONS ******
  event Paid(address sender, uint256 amount);
  function() external payable {
    emit Paid(msg.sender, msg.value);
  }
  function withdraw(uint256 amountWei)
  onlyBy(owner, owner) public{
    require(address(this).balance > amountWei, "Not enough Wei available for withdrawal.");
    if(address(this).balance > amountWei) {
      emit Transfer(address(this), owner, amountWei);
      msg.sender.transfer(amountWei);
    }
  }
  function getBalance()
  public view returns (uint256) {
    return address(this).balance;
  }
  // ****** END PAYABLE FUNCTIONS ******

  // ****** BEGIN ERC20 ******
  event Transfer(address indexed from, address indexed to, uint256 amount);
  //Transfer(address indexed from, address indexed to, uint256 value);
  function totalSupply() public view returns(uint256){
    return back.totalSupply();
  }
  function balanceOf(address tokenOwner) public view returns(uint256){
    return back.balanceOf(tokenOwner);
  }
  function allowance(address tokenOwner, address spender) public view returns(uint256){
    return back.allowance(tokenOwner, spender);
  }
  function transfer(address to, uint256 tokens) public returns(bool){
    emit Transfer(msg.sender, to, tokens);
    return back.transfer(to, tokens, msg.sender);
  }
  function approve(address spender, uint256 tokens) public returns(bool){
    return back.approve(spender, tokens, msg.sender);
  }
  function transferFrom(address from, address to, uint256 tokens) public returns(bool){
    emit Transfer(from, to, tokens);
    return back.transferFrom(from, to, tokens, msg.sender);
  }
  // ****** END ERC20 ******
}
