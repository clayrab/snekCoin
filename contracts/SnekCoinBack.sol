pragma solidity ^0.5.8;

import "./LibInterface.sol";
import "./lib/Ownable.sol";
//import "./PayableLib.sol";

// Just strips msg.value so lib can be called.
contract SnekCoinBack is Ownable {
  LibInterface.S public s;
  using LibInterface for LibInterface.S;
  //using snekCurrentVersion for address;
  /* struct LibInterface.S {
    uint256 creationTime;
    uint256 weiPriceToMine;
    uint256 snekPriceToMine;
    address owner;
    address root; //The Token contract which must be used for payable functions
    address snekCurrentVersion;
    mapping (address => uint32) allowanceNonces;
    uint256 newTotalSupply;
    // ****** BEGIN ERC20 ******
    uint256 totalSupp;
    bytes32 name;
    uint8 decimals;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    // ****** END ERC20 ******
  } */
  constructor(bytes32 nm, uint8 dec, uint256 ts) public {
    s.name = nm;
    s.decimals = dec;
    //s.balances[msg.sender] = ts;
    s.totalSupp = ts;
    //s.newTotalSupply = ts;
    s.balances[msg.sender] = ts;
    s.owner = msg.sender;
    s.root = address(this);
    s.weiPriceToMine = 500000000000; // 0.000001 ETH
    s.weiPricePerEgg = 1000000000000; // 0.000001 ETH
    s.snekPriceToMine = 1000000; // 0.000001 ETH
  }

  // ****** BEGIN TEST FUNCTIONS ******
  function getBackSender()
  public view returns(address){
    return msg.sender;
  }
  function getSender()
  public view returns(address){
    return s.getSender();
  }
  // ****** END TEST FUNCTIONS ******

  // ****** BEGIN BASIC FUNCTIONS ******
  function setRoot(address root)
  public onlyBy(owner, s.root) returns(bool){
    s.root = root;
    return true;
  }
  function getRoot()
  public view returns(address){
    return s.root;
  }
  function setOwner(address newOwner)
  public onlyBy(owner, s.root) returns(bool){
    s.owner = newOwner;
  }
  function getOwner()
  public view returns(address){
    return s.owner;
  }
  /* function distributeSupply()
  public onlyBy(owner, s.root) returns(uint256){
    if(s.newTotalSupply > 0) {
      uint256 newSupply = s.newTotalSupply;
      s.balances[s.owner] = SafeMath.add(s.balances[s.owner], newSupply);
      s.newTotalSupply = 0;
      return newSupply;
    }
    return 0;
  } */
  // ****** END BASIC FUNCTIONS ******

  // ****** BEGIN CONTRACT BUSINESS FUNCTIONS ******

  function changeMiningPrice(uint256 amount)
  public onlyBy(s.root, s.root) returns(bool){
    return s.changeMiningPrice(amount);
  }
  function changeMiningSnekPrice(uint256 amount)
  public onlyBy(s.root, s.root) returns(bool){
    return s.changeMiningSnekPrice(amount);
  }
  function changeEggPrice(uint256 amount)
  public onlyBy(s.root, s.root) returns(bool){
    return s.changeEggPrice(amount);
  }

  function getMiningPrice()
  public view returns(uint256){
    return s.getMiningPrice();
  }
  function getMiningSnekPrice()
  public view returns(uint256){
    return s.getMiningSnekPrice();
  }
  function getEggPrice()
  public view returns(uint256){
    return s.getEggPrice();
  }

  function getMiningRate()
  public view returns(uint256){
    return s.getMiningRate();
  }
  //function mine(uint256 amount, address sender, uint256 value)
  function mine(bytes32 signedMessage, uint8 sigV, bytes32 sigR, bytes32 sigS, address sender, uint256 value)
  public onlyBy(s.root, s.root) returns(uint256) {
    return s.mine(signedMessage, sigV, sigR, sigS, sender, value);
  }
  // function mineWithSnek(bytes32 signedMessage, uint8 sigV, bytes32 sigR, bytes32 sigS, address sender, uint256 payAmount)
  // public onlyBy(s.root, s.root) returns(uint256) {
  //   return s.mineWithSnek(signedMessage, sigV, sigR, sigS, sender, payAmount);
  // }

  // function mineForUser(address user, uint256 amount)
  // public onlyBy(s.root, s.root) returns(uint256) {
  //   return s.mineForUser(user, amount);
  // }
  function getUserNonce(address who)
  public view returns(uint32){
    return s.getUserNonce(who);
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
