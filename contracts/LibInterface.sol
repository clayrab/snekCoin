pragma solidity ^0.5.8;
import "./lib/Ownable.sol";
import "../contracts/lib/SafeMath.sol";
//import "./PayableLib.sol";
library LibInterface {
  using SafeMath for uint;

  struct S {
    uint256 creationTime;
    uint256 weiPriceToMine;
    uint256 snekPriceToMine;
    uint256 weiPricePerEgg;
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
  }
  modifier onlyBy(address account1, address account2) {
    require(
      msg.sender == account1 || msg.sender == account2 ,
      "Sender not authorized."
    );
    _;
  }
  // ****** BEGIN TEST FUNCTIONS ******
  function getSender(S storage s) public view returns(address);
  // ****** END TEST FUNCTIONS ******

  // ****** BEGIN BASIC FUNCTIONS ******
  /* function setRoot(S storage s, address root) public returns(bool);
  function getRoot(S storage s) public view returns(address); */
  // ****** END BASIC FUNCTIONS ******

  // ****** BEGIN CONTRACT BUSINESS FUNCTIONS ******

  function changeMiningPrice(S storage s, uint256 amount)public returns(bool);
  function changeMiningSnekPrice(S storage s, uint256 amount) public returns(bool);
  function changeEggPrice(S storage s, uint256 amount) public returns(bool);
  function getMiningPrice(S storage s) public view returns(uint256);
  function getMiningSnekPrice(S storage s) public view returns(uint256);
  function getEggPrice(S storage s) public view returns(uint256);
  function getMiningRate(S storage s) public view returns(uint256);
  function mine(S storage s, bytes32 signedMessage, uint8 sigV, bytes32 sigR, bytes32 sigS, address sender, uint256 value) public returns(uint256);
  // function mineWithSnek(S storage s, bytes32 signedMessage, uint8 sigV, bytes32 sigR, bytes32 sigS, address sender, uint256 payAmount) public returns(uint256);
  // function mineForUser(S storage s, address user, uint256 amount) public returns(uint256);
  function getUserNonce(S storage s, address who) public view returns(uint32);
  // ****** END CONTRACT BUSINESS FUNCTIONS ******


  // ****** BEGIN ERC20 ******
  function totalSupply(S storage s) public view returns(uint256);
  function balanceOf(S storage s, address tokenOwner) public view returns(uint256);
  function allowance(S storage s, address tokenOwner, address spender) public view returns (uint256);
  function transfer(S storage s, address to, uint256 tokens, address sender) public returns (bool);
  function approve(S storage s, address spender, uint256 tokens, address sender) public returns (bool);
  function transferFrom(S storage s, address from, address to, uint256 tokens, address sender) public returns (bool);

  /* event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens); */
  // ****** END ERC20 ******
}
