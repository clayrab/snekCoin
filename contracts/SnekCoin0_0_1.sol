pragma solidity ^0.5.8;

import "../contracts/LibInterface.sol";
import "../contracts/lib/SafeMath.sol";

library SnekCoin0_0_1 {
  using SafeMath for uint;
  uint32 constant tokensPerLevel = 1024 * 10000;

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

  function changeMiningPrice(LibInterface.S storage s, uint256 amount)
  public onlyBy(s.root, s.root) returns(bool){
      s.weiPriceToMine = amount;
  }
  function changeMiningSnekPrice(LibInterface.S storage s, uint256 amount)
  public onlyBy(s.root, s.root) returns(bool){
    s.snekPriceToMine = amount;
  }
  function changeEggPrice(LibInterface.S storage s, uint256 amount)
  public onlyBy(s.root, s.root) returns(bool){
    s.weiPricePerEgg = amount;
  }

  function getMiningPrice(LibInterface.S storage s)
  public view onlyBy(s.root, s.root) returns(uint256){
    return s.weiPriceToMine;
  }
  function getMiningSnekPrice(LibInterface.S storage s)
  public view onlyBy(s.root, s.root) returns(uint256){
    return s.snekPriceToMine;
  }
  function getEggPrice(LibInterface.S storage s)
  public view onlyBy(s.root, s.root) returns(uint256){
    return s.weiPricePerEgg;
  }
  // It is possible to mine "extra" by sending the last mine() call in a particular level and hatching many eggs.
  // Therefore, the actual total supply at the end will be slightly above what it would be by mining only one egg at a time.
  // However, the Nash Equilibrium guarantees that this cannot be exploied for very many eggs, and I doubt anyone will try to claim
  // too many "over-valuable eggs" via this method.
  // Likely, when some X number of eggs are remaining, someone with ~2X eggs will hatch them. Also note that there is a risk of holding eggs
  // during this period, since at any moment someone can hatch X eggs and make your unhatched eggs half as valuable. Therefore even people with
  // a small number of eggs will be hatching them more frequently than usual at this point.
  function getMiningRate(LibInterface.S storage s)
  public view onlyBy(s.root, s.root) returns(uint256){
    if (s.totalSupp < tokensPerLevel) {
      return 1024;
    } else if (s.totalSupp < 2 * tokensPerLevel) {
      return 512;
    } else if (s.totalSupp < 3 * tokensPerLevel) {
      return 256;
    } else if (s.totalSupp < 4 * tokensPerLevel) {
      return 128;
    } else if (s.totalSupp < 5 * tokensPerLevel) {
      return 64;
    } else if (s.totalSupp < 6 * tokensPerLevel) {
      return 32;
    } else if (s.totalSupp < 7 * tokensPerLevel) {
      return 16;
    } else if (s.totalSupp < 8 * tokensPerLevel) {
      return 8;
    } else if (s.totalSupp < 9 * tokensPerLevel) {
      return 4;
    } else if (s.totalSupp < 10 * tokensPerLevel) {
      return 2;
    } else if (s.totalSupp < 11 * tokensPerLevel) {
      return 1;
    } else {
      return 0;
    }
  }

  function mine(LibInterface.S storage s, bytes32 signedMessage, uint8 sigV, bytes32 sigR, bytes32 sigS, address sender, uint256 value)
  public onlyBy(s.root, s.root) returns(uint256) {
    // Data is 3 uints packed into bytes32 as hex: 1337beef + pubkey + allowance nonce + amount.
    // pubkey = 20 bytes, nonce = 4 bytes, amount = 4 bytes.
    // Total size = 224 bits = 160 + 32 + 32 bits = 28 bytes = 40hex pubkey, 8 hex nonce, 8 hex amount = (40*8*8)*4 hex chars
    // Bytes32 also convenient for sha3/keccak256 to work across web3 + solidity.
    uint256 miningRate = getMiningRate(s);

    uint256 rawData = uint256(signedMessage) & (2**224-1);
    uint32 amount = uint32(rawData & (2**32-1));
    rawData = rawData / (2**32);
    uint32 nonce = uint32(rawData & (2**32-1));
    rawData = rawData / (2**32);
    address user = address(rawData);

    require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", signedMessage)), sigV, sigR, sigS) == s.owner, "Not approved by owner");
    require(user == sender, "Not Approved User");
    require(nonce == s.allowanceNonces[sender] , "Not Approved Nonce");
    require(value == (amount * s.weiPricePerEgg) + s.weiPriceToMine, "Incorrect price paid");
    //require(amount == howManyEggs * getMiningRate(s), "Amount approved does not match");
    // require(s.totalSupp < 12 * tokensPerLevel, "total supply already distributed");
    //require(amount == howManyEggs * getMiningRate(s), "Amount approved does not match");
    //require(amount == howManyEggs * miningRate, "Amount approved does not match");

    s.balances[sender] = SafeMath.add(s.balances[sender], (amount * miningRate));
    s.allowanceNonces[sender] = s.allowanceNonces[sender] + 1;
    s.totalSupp = SafeMath.add(s.totalSupp, (amount * miningRate));
    return amount;
  }
  // function mineWithSnek(LibInterface.S storage s, bytes32 signedMessage, uint8 sigV, bytes32 sigR, bytes32 sigS, address sender, uint256 payAmount)
  // public onlyBy(s.root, s.root) returns(uint256){
  //   uint256 rawData = uint256(signedMessage) & (2**224-1);
  //   uint32 amount = uint32(rawData & (2**32-1));
  //   rawData = rawData / (2**32);
  //   uint32 nonce = uint32(rawData & (2**32-1));
  //   rawData = rawData / (2**32);
  //   //address user = address(rawData);
  //   require(payAmount >= s.snekPriceToMine, "Not enough snek sent");
  //   //require(amount - payAmount >= s.balances[sender], "Not enough snek in wallet");
  //   require(ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", signedMessage)), sigV, sigR, sigS) == s.owner, "Not approved by owner");
  //   require(address(rawData) == sender, "Not Approved User");
  //   require(nonce == s.allowanceNonces[sender] , "Not Approved Nonce");
  //   s.balances[sender] = SafeMath.sub(SafeMath.add(s.balances[sender], amount), payAmount);
  //   s.balances[s.owner] = SafeMath.add(s.balances[s.owner], payAmount);
  //   s.allowanceNonces[sender] = s.allowanceNonces[sender] + 1;
  //   s.totalSupp = SafeMath.add(s.totalSupp, amount);
  //   return amount;
  // }

  function mineForUser(LibInterface.S storage s, address user, uint256 amount)
  public onlyBy(s.root, s.root) returns(uint256) {
    s.balances[user] = SafeMath.add(s.balances[user], amount);
    s.allowanceNonces[user] = s.allowanceNonces[user] + 1;
    s.totalSupp = SafeMath.add(s.totalSupp, amount);
    return amount;
  }
  function getUserNonce(LibInterface.S storage s, address who)
  public view returns(uint32) {
    return s.allowanceNonces[who];
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
