pragma solidity ^0.4.10;

import "./LibInterface.sol";
import "./lib/Ownable.sol";

contract SnekCoin is Ownable {
  LibInterface.S s;
  using LibInterface for LibInterface.S;

  constructor(bytes32 nm, uint8 dec, uint256 ts) public {
    s.name = nm;
    s.decimals = dec;
    s.totalSupp = ts;
    s.balances[msg.sender] = ts;
    s.root = address(this);
  }

  // ****** BEGIN BASIC FUNCTIONS ******
  function setRoot(address root)
  public returns(bool){
    return s.setRoot(root);
  }
  function getRoot()
  public returns(address){
    return s.getRoot();
  }
  // ****** END BASIC FUNCTIONS ******

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

  // ****** BEGIN CONTRACT BUSINESS FUNCTIONS ******
  function mine(uint256 amount, uint256 ethAmount)
  public payable returns(bool) {
    require(msg.value == ethAmount); //validate
    if(msg.value >= s.weiPriceToMine) {
      s.mine(amount, ethAmount);
    } else {
      msg.sender.transfer(msg.value);
    }
  }
  // ****** END CONTRACT BUSINESS FUNCTIONS ******

  // ****** BEGIN ERC20 ******
  function totalSupply() public constant returns(uint256){
    return s.totalSupply();
  }
  function balanceOf(address tokenOwner) public constant returns (uint256){
    return s.balanceOf(tokenOwner);
  }
  function allowance(address tokenOwner, address spender) public constant returns (uint256){
    return s.allowance(tokenOwner, spender);
  }
  function transfer(address to, uint tokens) public returns (bool){
    return s.transfer(to, tokens);
  }
  function approve(address spender, uint tokens) public returns (bool){
    return s.approve(spender, tokens);
  }
  function transferFrom(address from, address to, uint tokens) public returns (bool){
    return s.transferFrom(from, to, tokens);
  }
  // ****** END ERC20 ******
}
