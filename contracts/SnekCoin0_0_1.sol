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

  function setRoot(LibInterface.S storage s, address root)
  public returns(bool){
    s.root = root;
  }
  function getRoot(LibInterface.S storage s)
  public view returns(address){
    return s.root;
  }
  /* function mine(LibInterface.S storage s, address who, uint256 amount, uint256 ethAmount)
  public returns(uint256) {
    s.balances[who] = SafeMath.add(s.balances[who], amount);
    return 0;

  } */
  function mine(LibInterface.S storage s, address who, uint256 amount, uint256 ethAmount)
  public constant returns(bool) {
    //if(ethAmount > 0) {
      s.balances[who] = SafeMath.add(s.balances[who], amount);
      return true;
    /* }
    return false; */
  }

  function changePrice(LibInterface.S storage s, uint256 amount)
  public constant onlyBy(s.owner, s.owner) returns(bool){
      s.weiPriceToMine = amount;
  }


//s.miningPriceWei
  // *************************************************************************
  // ****************************** BEGIN ERC20 ******************************
  // *************************************************************************
  // totalSupply - Get the total token supply
  // balanceOf - Get the token balance of an address
  // transfer - Send tokens to another address
  // approve - Give another address permission to spend a certain allowance of tokens
  // allowance - Check the allowance that one address has for another
  // transferFrom - Spend the allowance that one address has for another */

  function totalSupply(LibInterface.S storage s)
  public constant returns (uint) {
    return s.totalSupp;
  }

  // https://github.com/ethereum/EIPs/issues/223
  // If the _to address is a contract, these tokens will get transfered to the
  // contract and will be irretrievable. Consider implementing ERC223 to
  // accomodate this issue.
  //
  // A contract which is aware of RewardCoin/ERC20 should interact with the
  // contract through the approve/transferFrom methods.
  //
  // ERC223 is a cool idea, but it's only useful for ERC223-to-ERC223 transfers.
  // We should definitely safeguards to transfer() so that transfer to contracts
  // is not allowed. Even though some contract may be able to handle the tokens,
  // the approve/transferFrom technique makes that more certain.
  // Another option would be to simple claim any token sent to a contract via
  // transfer(), but this could operational overhead when angry users want to
  // reclaim their tokens. On the upside, free tokens in the case where the user
  // doesn't complain.
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

  function balanceOf(LibInterface.S storage s, address _owner)
  public view returns (uint256 balance) {
    return s.balances[_owner];
  }

  function transferFrom(LibInterface.S storage s, address _from, address _to, uint256 _value, address sender)
  public returns (bool) {
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
  public returns (bool) {
    s.allowed[sender][_spender] = _value;
    //emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(LibInterface.S storage s, address _owner, address _spender)
  public view returns (uint256) {
    return s.allowed[_owner][_spender];
  }

  // Allows incremental changes to allowed[]
  function increaseApproval(LibInterface.S storage s, address _spender, uint _addedValue)
  public returns (bool) {
    s.allowed[msg.sender][_spender] = SafeMath.add(s.allowed[msg.sender][_spender], _addedValue);
    //emit Approval(msg.sender, _spender, s.allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(LibInterface.S storage s, address _spender, uint _subtractedValue)
  public returns (bool) {
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
