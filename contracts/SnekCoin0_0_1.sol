pragma solidity ^0.4.10;

import "../contracts/LibInterface.sol";
import "../contracts/lib/SafeMath.sol";

library SnekCoin0_0_1 {
  using SafeMath for uint;

  modifier onlyBy(address account1, address account2) {
    require(
      msg.sender == account1 || msg.sender == account2 ,
      "Sender not authorized."
    );
    _;
  }

  function getSender(LibInterface.S storage s)
  public view returns(address){
    return msg.sender;
  }

  function approveMine(LibInterface.S storage s, address who, uint256 amount)
  public onlyBy(s.root, s.root) returns(bool){
    s.approvedMines[who] = amount;
    return true;
  }
  function isMineApproved(LibInterface.S storage s, address who)
  public view onlyBy(s.root, s.root) returns(uint256){
    return s.approvedMines[who];
  }
  
  function changeMiningPrice(LibInterface.S storage s, uint256 amount)
  public onlyBy(s.root, s.root) returns(bool){
      s.weiPriceToMine = amount;
  }
  function changeMiningSnekPrice(LibInterface.S storage s, uint256 amount)
  public onlyBy(s.root, s.root) returns(bool){
    s.snekPriceToMine = amount;
  }

  function getMiningPrice(LibInterface.S storage s)
  public view onlyBy(s.root, s.root) returns(uint256){
    return s.weiPriceToMine;
  }
  function getMiningSnekPrice(LibInterface.S storage s)
  public view onlyBy(s.root, s.root) returns(uint256){
    return s.snekPriceToMine;
  }

  function mine(LibInterface.S storage s, uint256 amount, address sender, uint256 value)
  public onlyBy(s.root, s.root) returns(bool){
    require(value >= s.weiPriceToMine, "Not enough ethereum");
    require(s.approvedMines[sender] >= amount,"Not approved");
    s.balances[sender] = SafeMath.add(s.balances[sender], amount);
    s.approvedMines[sender] = SafeMath.sub(s.approvedMines[sender], amount);
    s.totalSupp = SafeMath.add(s.totalSupp, amount);
    return true;
  }
  function mineWithSnek(LibInterface.S storage s, uint256 amount, address sender, uint256 payAmount)
  public onlyBy(s.root, s.root) returns(bool){
    require(payAmount >= s.snekPriceToMine, "Not enough snek");
    require(s.approvedMines[sender] >= amount, "Not approved");
    require(amount - payAmount >= s.balances[sender], "Not enough snek in wallet");
    s.balances[sender] = SafeMath.sub(SafeMath.add(s.balances[sender], amount), payAmount);
    s.balances[s.owner] = SafeMath.add(s.balances[s.owner], payAmount);
    s.approvedMines[sender] = SafeMath.sub(s.approvedMines[sender], amount);
    s.totalSupp = SafeMath.add(s.totalSupp, amount);
    return true;
  }

  // *************************************************************************
  // ****************************** BEGIN ERC20 ******************************
  // *************************************************************************
  // totalSupply - Get the total token supply
  // balanceOf - Get the token balance of an address
  // transfer - Send tokens to another address
  // approve - Give another address permission to spend a certain allowance of tokens
  // allowance - Check the allowance that one address has for another
  // transferFrom - Spend the allowance that one address has for another */

  function totalSupply(LibInterface.S storage s) public view returns(uint256) {
    return s.totalSupp;
  }

  function balanceOf(LibInterface.S storage s, address _owner)
  public view returns(uint256) {
    return s.balances[_owner];
  }

  function allowance(LibInterface.S storage s, address _owner, address _spender)
  public view returns(uint256) {
    return s.allowed[_owner][_spender];
  }

  function transfer(LibInterface.S storage s, address _to, uint256 _value, address sender)
  public returns(bool) {
    // Address(0) is 0x0. It is the burn address for ETH.
    // When used in the tx.to field, will cause the tx to create a new contract
    require(_to != address(0));
    require(_value <= s.balances[sender]);
    s.balances[sender] = SafeMath.sub(s.balances[sender], _value);
    s.balances[_to] = SafeMath.add(s.balances[_to], _value);
    //emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(LibInterface.S storage s, address _from, address _to, uint256 _value, address sender)
  public returns(bool) {
    require(_to != address(0));
    require(_value <= s.balances[_from]);
    require(_value <= s.allowed[_from][sender]);
    s.balances[_from] = SafeMath.sub(s.balances[_from], _value);
    s.balances[_to] = SafeMath.add(s.balances[_to], _value);
    s.allowed[_from][sender] = SafeMath.sub(s.allowed[_from][sender], _value);
    //emit LibInterface.Transfer(_from, _to, _value);
    return true;
  }

  // Approve allows a token holder to allocate some coins to an address without
  // specifying the amount. This has a few usecases, but the main reason this
  // is done is for contract-to-contract interoperability. Since contracts
  // cannot listen for events so they will never be notified when they receive
  // tokens.
  //
  // If a user wants to send RewardCoin tokens to another contract, the user
  // should first approve the transfer to the contract's address. The user
  // can then call a function in the contract(e.g. buyWithRewardCoin) that will
  // will then call transferFrom.
  function approve(LibInterface.S storage s, address _spender, uint256 _value, address sender)
  public returns(bool) {
    s.allowed[sender][_spender] = _value;
    //emit Approval(msg.sender, _spender, _value);
    return true;
  }


  // Allows incremental changes to allowed[]
  function increaseApproval(LibInterface.S storage s, address _spender, uint _addedValue)
  public returns(bool) {
    s.allowed[msg.sender][_spender] = SafeMath.add(s.allowed[msg.sender][_spender], _addedValue);
    //emit Approval(msg.sender, _spender, s.allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(LibInterface.S storage s, address _spender, uint _subtractedValue)
  public returns(bool) {
    uint oldValue = s.allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      s.allowed[msg.sender][_spender] = 0;
    } else {
      s.allowed[msg.sender][_spender] = SafeMath.sub(oldValue, _subtractedValue);
    }
    //emit Approval(msg.sender, _spender, s.allowed[msg.sender][_spender]);
    return true;
  }
  // *************************************************************************
  // ****************************** END ERC20 ******************************
  // *************************************************************************
}
