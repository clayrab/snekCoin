pragma solidity ^0.4.10;
import "./lib/Ownable.sol";

library LibInterface {
  struct S {
    uint256 creationTime;
    uint256 weiPriceToMine;
    address owner;
    // ****** BEGIN ERC20 ******
    uint256 totalSupp;
    bytes32 name;
    uint8 decimals;
    address root; //real contract which must be used for payable functions
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    // ****** END ERC20 ******
  }

  modifier onlyBy(address account1, address account2) {
    require(
      msg.sender == account1 || msg.sender == account2 ,
      "Sender not authorized."
    );
    _;
  }
  // ****** BEGIN BASIC FUNCTIONS ******
  function setRoot(S storage s, address root) public returns(bool);
  function getRoot(S storage s) public returns(address);
  // ****** END BASIC FUNCTIONS ******

  // ****** BEGIN CONTRACT BUSINESS FUNCTIONS ******

  function mine(S storage s, uint256 amount, uint256 ethAmount) public returns(bool);
  function changePrice(S storage s, uint256 amount) public onlyBy(s.owner, s.owner) returns(bool);
  // ****** END CONTRACT BUSINESS FUNCTIONS ******


  // ****** BEGIN ERC20 ******
  function totalSupply(S storage s) public constant returns (uint256);
  function balanceOf(S storage s, address tokenOwner) public constant returns (uint256);
  function allowance(S storage s, address tokenOwner, address spender) public constant returns (uint256);
  function transfer(S storage s, address to, uint256 tokens) public returns (bool);
  function approve(S storage s, address spender, uint256 tokens) public returns (bool);
  function transferFrom(S storage s, address from, address to, uint tokens) public returns (bool);

  /* event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens); */
  // ****** END ERC20 ******
}
