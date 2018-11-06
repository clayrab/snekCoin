pragma solidity ^0.4.10;
import "./lib/Ownable.sol";
import "../contracts/lib/SafeMath.sol";
//import "./PayableLib.sol";
library LibInterface {
  using SafeMath for uint;

  struct S {
    uint256 creationTime;
    uint256 weiPriceToMine;
    address owner;
    address snekCurrentVersion;
    // ****** BEGIN ERC20 ******
    uint256 totalSupp;
    bytes32 name;
    uint8 decimals;
    address root; //real contract which must be used for payable functions
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) approvedMines;
    // ****** END ERC20 ******
  }
  event RequestMine(
    address who,
    uint256 amount,
    uint256 ethAmount
  );
  event RequestMineWithSnek(
    address who,
    uint256 amount,
    uint256 ethAmount
  );
  modifier onlyBy(address account1, address account2) {
    require(
      msg.sender == account1 || msg.sender == account2 ,
      "Sender not authorized."
    );
    _;
  }
  // ****** BEGIN TEST FUNCTIONS ******
  function getSender(S storage s) public constant returns(address);
  // ****** END TEST FUNCTIONS ******

  // ****** BEGIN BASIC FUNCTIONS ******
  /* function setRoot(S storage s, address root) public returns(bool);
  function getRoot(S storage s) public view returns(address); */
  // ****** END BASIC FUNCTIONS ******

  // ****** BEGIN CONTRACT BUSINESS FUNCTIONS ******

  function mine(S storage s, uint256 amount, address sender, uint256 value) public returns(bool);
  function approveMine(S storage s, address who, uint256 amount) public returns(bool);
  function isMineApproved(S storage s, address who) public view returns(uint256);
  function changeMiningPrice(S storage s, uint256 amount) public returns(bool);
  function getMiningPrice(S storage s) public view returns(uint256);
  // ****** END CONTRACT BUSINESS FUNCTIONS ******


  // ****** BEGIN ERC20 ******
  function totalSupply(S storage s) public constant returns(uint256);
  function balanceOf(S storage s, address tokenOwner) public view returns(uint256);
  function allowance(S storage s, address tokenOwner, address spender) public view returns (uint256);
  function transfer(S storage s, address to, uint256 tokens, address sender) public returns (bool);
  function approve(S storage s, address spender, uint256 tokens, address sender) public returns (bool);
  function transferFrom(S storage s, address from, address to, uint256 tokens, address sender) public returns (bool);

  /* event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens); */
  // ****** END ERC20 ******
}
