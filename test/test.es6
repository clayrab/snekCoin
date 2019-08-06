'use strict';

const Dispatcher = artifacts.require('Dispatcher.sol');
const DispatcherStorage = artifacts.require('DispatcherStorage.sol');
const SnekCoinBack = artifacts.require('SnekCoinBack.sol');
const SnekCoinToken = artifacts.require('SnekCoinToken.sol');
const SnekCoin0_0_1 = artifacts.require('SnekCoin0_0_1.sol');
const SnekCoin0_0_X = artifacts.require('./SnekCoin0_0_X.sol');

const TheContract = artifacts.require('./TheContract.sol');
const ExampleVersion1 = artifacts.require('./Example.sol');
const ExampleReverts = artifacts.require('./ExampleReverts.sol');
const ExampleVersion2 = artifacts.require('./ExampleVersion2.sol');

// let nonce = 0;
// let amount = 1000;

contract('Test Contracts', (accounts) => {
  let owner  = accounts[0];
  let user1 = accounts[1];
  let user2  = accounts[2];
  let user3  = accounts[3];
  let user4  = accounts[4];
  let vins = ["1J4GW68S9XC654116",
              "1J4GW68S9XC612345"];
  let unixTime = 1514764800; // Jan 1 2018

  let snek001;
  let snek00x;
  let dispatcherStorage;
  let dispatcher;
  let snekcoinback;
  let snekcointoken;
  let snekcoinback2;
  let snekcointoken2;
  let snekcoinback3;
  let snekcointoken3;
  let snekcoinback4;
  let snekcointoken4;
  let fakesnekcointoken;

  let exampleVersion1;
  let exampleVersion2;
  let exampleDispatcherStorage;
  let exampleDispatcher;

  let thecontract;
  let fakeUser = "0x0000000000000000000000000000000000000000";
  let initSupply = 10239000;

  async function signAs(ownr, nonce, amount, forUser) {
    let ret = [];
    let data = (nonce * 2 ** 32) + amount;
    let hexData = web3.utils.toHex(data).slice(2)
    for(let i = hexData.length; i < 16; i++) {
      hexData = "0" + hexData
    }
    let message = "0x1337beef" + forUser.slice(2) + hexData;
    //let msg = web3.sha3(hexData, {encoding: "hex"}); // 256 bit number as hex-encoded string.
    //let sig = web3.eth.sign(message, ownr).slice(2);
    let sig = (await web3.eth.sign(message, ownr)).slice(2);
    let r = "0x" + sig.slice(0, 64);
    let s = "0x" + sig.slice(64, 128);
    let v = web3.utils.toDecimal('0x' + sig.slice(128, 130)) + 27
    ret.push(message);
    ret.push(v);
    ret.push(r);
    ret.push(s);
    return ret;
  }
  describe('SnakeChain Tests', function() {
    before(async() => {
      // Instantiate, initialize, and link contracts
      exampleVersion1 = await ExampleVersion1.new();
      exampleDispatcherStorage = await DispatcherStorage.new(exampleVersion1.address);
      Dispatcher.unlinked_binary = Dispatcher.unlinked_binary
          .replace('1111222233334444555566667777888899990000',
              exampleDispatcherStorage.address.slice(2));
      exampleDispatcher = await Dispatcher.new();
      TheContract.link('LibInterfaceExample', exampleDispatcher.address);
      thecontract = await TheContract.new();

      snek001 = await SnekCoin0_0_1.new();
      snek00x = await SnekCoin0_0_X.new();
      dispatcherStorage = await DispatcherStorage.new(snek001.address);
      Dispatcher.unlinked_binary = Dispatcher.unlinked_binary
          .replace(exampleDispatcherStorage.address.slice(2),
              dispatcherStorage.address.slice(2));
      dispatcher = await Dispatcher.new();
      SnekCoinBack.link('LibInterface', dispatcher.address);
      //snekcoinback = await SnekCoinBack.new(web3.utils.fromAscii("TestContract"), 20, initSupply);
      snekcoinback = await SnekCoinBack.new(web3.utils.fromAscii("TestContract"), 20, initSupply);
      snekcointoken = await SnekCoinToken.new(snekcoinback.address);
      snekcoinback.setRoot(snekcointoken.address);

      snekcoinback2 = await SnekCoinBack.new(web3.utils.fromAscii("TestContract2"), 20, 10240000);
      snekcointoken2 = await SnekCoinToken.new(snekcoinback2.address);
      snekcoinback2.setRoot(snekcointoken2.address);

      snekcoinback3 = await SnekCoinBack.new(web3.utils.fromAscii("TestContract2"), 20, 10240000*10);
      snekcointoken3 = await SnekCoinToken.new(snekcoinback3.address);
      snekcoinback3.setRoot(snekcointoken3.address);

      snekcoinback4 = await SnekCoinBack.new(web3.utils.fromAscii("TestContract2"), 20, 10240000*11);
      snekcointoken4 = await SnekCoinToken.new(snekcoinback4.address);
      snekcoinback4.setRoot(snekcointoken4.address);

      fakesnekcointoken = await SnekCoinToken.new(snekcoinback.address);

    });


    it('only owner can set the root', async () => {
      snekcoinback.setRoot(snekcointoken.address, {from: user1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
      snekcoinback.setRoot(snekcointoken.address, {from: owner});
    });
    it('snekcointoken can do owner things', async () => {
      var _owner = await snekcointoken.owner.call();
      assert.equal(_owner, owner, "expected owner to be accounts[0]");
      await snekcointoken.changeOwner(user1);
      var newOwner = await snekcointoken.owner.call();
      assert.equal(newOwner, user1, "expected owner to be accounts[1]");
      await snekcointoken.changeOwner(owner, {from: user1});
      var finalOwner = await snekcointoken.owner.call();
      assert.equal(finalOwner, owner, "expected owner to be accounts[1]");
    });
    it('snekcointoken can do special owner things', async () => {
      //TODO
    });
    it('snekcointoken can get user nonce', async () => {
      let fakeUserNonce = await snekcointoken.getUserNonce.call(fakeUser);
      let user1Nonce = await snekcointoken.getUserNonce.call(user1);
    });

    it('can versioning', async () => {
      await thecontract.set(10);
      const x = await thecontract.get();
      assert.equal(x.toNumber(), 10);
      exampleVersion2 = await ExampleVersion2.new();
      await exampleDispatcherStorage.replace(exampleVersion2.address);
      const x2 = await thecontract.get();
      assert.equal(x2.toNumber(), 10 * 10); // ExampleVersion2 multiplies by 10

      const exampleReverts = await ExampleReverts.new();
      await exampleDispatcherStorage.replace(exampleReverts.address);
      thecontract.get().then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
    });

    it("snekcoin can be updated", async function() {
      var totalSupply = await snekcointoken.totalSupply.call();
      assert.equal(initSupply, totalSupply.toNumber(), "expected supply of " + initSupply);
      // break it!
      await dispatcherStorage.replace(snek00x.address);
      totalSupply = await snekcointoken.totalSupply.call();
      assert.equal(totalSupply.toNumber(), initSupply * 10, "expected supply to be 10x");
      // REALLY BREAK IT!!
      await dispatcherStorage.replace("0x0000000000000000000000000000000000000000");
      snekcointoken.totalSupply.call().then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
      // And put it back to normal...
      await dispatcherStorage.replace(snek001.address);
      totalSupply = await snekcointoken.totalSupply.call();
      assert.equal(initSupply, totalSupply.toNumber(), "expected supply of " + initSupply);
    });

    it("snekcoin root should be SnekCoin", async function() {
      var root = await snekcointoken.getRoot.call();
      assert.equal(snekcointoken.address, root, "expected adddress of root to be snekcoin");
    });
    it("snekcoin should have total supply 1000000 or more", async function() {
      var totalSupply = await snekcointoken.totalSupply.call();
      assert.equal(initSupply, totalSupply.toNumber(), "expected supply of " + initSupply);
    });
    it("snekcoin owner should have total supply", async function() {
      var totalSupply = await snekcointoken.totalSupply.call();
      var ownerBalance = await snekcointoken.balanceOf(owner);
      assert.equal(ownerBalance.toNumber(), totalSupply.toNumber(), "expected owner to have supply");
    });

    it("snekcoin can be transferred", async function() {
      var ownerBalance = await snekcointoken.balanceOf(owner);
      var user1Balance = await snekcointoken.balanceOf(user1);
      await snekcointoken.transfer(user1, 1000, {from: owner});
      var newOwnerBalance = await snekcointoken.balanceOf(owner);
      //console.log(out.toNumber());
      var newUser1Balance = await snekcointoken.balanceOf(user1);
      assert.equal(newOwnerBalance.toNumber(), ownerBalance.toNumber() - 1000, "");
      assert.equal(newUser1Balance.toNumber(), user1Balance.toNumber() + 1000, "");
    });

    it("snekcoin can be transferred through allowanance", async function() {
      var ownerBalance = await snekcointoken.balanceOf(owner);
      var user2Balance = await snekcointoken.balanceOf(user2);
      var status = await snekcointoken.approve(user1, 2, {from: owner});
      var allowance = await snekcointoken.allowance(owner, user1, {from: owner});
      assert.equal(allowance.toNumber(), 2, "");
      var status = await snekcointoken.transferFrom(owner, user2, 1, {from: user1});
      var newOwnerBalance = await snekcointoken.balanceOf(owner);
      var newUser2Balance = await snekcointoken.balanceOf(user2);
      assert.equal(newOwnerBalance.toNumber(), ownerBalance.toNumber() - 1, "");
      assert.equal(newUser2Balance.toNumber(), user2Balance.toNumber() + 1, "");
    });

    it("snekcoin can receive and send eth", async function() {
      // can receive
      var startEth = await snekcointoken.getBalance.call();
      var ownerStartEth = web3.eth.getBalance(owner);
      await web3.eth.sendTransaction({from: owner, to: snekcointoken.address, value: web3.utils.toWei("0.000003", "ether"), gas: 200000 });

      var endEth = await snekcointoken.getBalance.call();
      var ownerEndEth = web3.eth.getBalance(owner);
      assert.equal(startEth.toNumber(), endEth.toNumber() - web3.utils.toWei("0.000003", "ether"), "expected eth to move");
      //can withdraw
      startEth = await snekcointoken.getBalance.call();
      await snekcointoken.withdraw(web3.utils.toWei("0.000001", "ether"), {from: owner});
      endEth = await snekcointoken.getBalance.call();
      assert.equal(startEth.toNumber(), endEth.toNumber() + 1000000000000, "expected eth to move");
      // only owner can withdraw
      snekcointoken.withdraw(web3.utils.toWei("0.000001", "ether"), {from: user1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "withdraw expected revert, but got none");
      });
      // owner cannot draw more than is available
      snekcointoken.withdraw(web3.utils.toWei("0.001", "ether"), {from: owner}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "withdrawal expected revert, but got none");
      });
    });

    it("can sign", async () => {
      //signAs(ownr, nonce, amount, forUser) {
      //let sigData = await signAs(owner, 0, 1000, "0x627306090abaB3A6e1400e9345bC60c78a8BEf57");
      //signAs
    });
    it('snekcointoken can be mined', async () => {
      //let fakeUser = "0x0000000000000000000000000000000000000000000000000000000000000000000000000000"
      let fakeUserNonce = await snekcointoken.getUserNonce.call(fakeUser);
      let user1Nonce = await snekcointoken.getUserNonce.call(user1);
      var user1Balance = await snekcointoken.balanceOf(user1);
      var totalSupply = await snekcointoken.totalSupply();
      let badSigPart = "0x0000000000000000000000000000000000000000000000000000000000000000";

      // prices can be changed
      await snekcointoken.changeMiningPrice(1000000, {from: owner});
      var miningPrice = await snekcointoken.getMiningPrice();
      assert.equal(miningPrice.toNumber(), 1000000, "expected 100000");

      await snekcointoken.changeEggPrice(1000000, {from: owner});
      var eggPrice = await snekcointoken.getEggPrice();
      assert.equal(eggPrice.toNumber(), 1000000, "expected 1000000");

      let tokensPerEgg = await snekcointoken.getMiningRate({from: user2});
      let howManyEggs = 2;
      let price = (howManyEggs * eggPrice.toNumber()) + miningPrice.toNumber();
      let howMany = howManyEggs*tokensPerEgg.toNumber();
      let sigData = await signAs(owner, user1Nonce, howMany, user1);

      // prices can only be changed by owner
      await snekcointoken.changeMiningPrice(1, {from: user1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected unapproved revert 1");
      });
      await snekcointoken.changeEggPrice(1, {from: user1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected unapproved revert 2");
      });

      // mining must be approved
      await snekcointoken.mine(sigData[0], sigData[1], badSigPart, sigData[3], 1, {from: user1, value: price}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isTrue(error.toString().startsWith("Error: Returned error: VM Exception while processing transaction: revert Not approved by owner -- Reason given: Not approved by owner"), "Expected unapproved revert 3");
      });
      //...by owner
      let fakeSigData = await signAs(user1, 0, 1000, user1);
      await snekcointoken.mine(fakeSigData[0], fakeSigData[1], fakeSigData[2], fakeSigData[3], 100, {from: user1, value: price}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isTrue(error.toString().startsWith("Error: Returned error: VM Exception while processing transaction: revert Not approved by owner -- Reason given: Not approved by owner."), "Expected user1 can't approve");
      });
      // sending less than the price will yield nothing
      await snekcointoken.mine(sigData[0], sigData[1], sigData[2], sigData[3], howManyEggs, {from: user1, value: 1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isTrue(error.toString().startsWith("Error: Returned error: VM Exception while processing transaction: revert Not enough ethereum -- Reason given: Not enough ethereum."), "Expected sending less than the price will yield nothing");
      });

      await snekcointoken.mine(sigData[0], sigData[1], sigData[2], sigData[3], howManyEggs, {from: user1, value: price});
      var newUser1Balance = await snekcointoken.balanceOf(user1);
      assert.equal(user1Balance.toNumber() + howMany, newUser1Balance.toNumber(), "expected " + howMany + " more");

      //replaying the sig fails
      await snekcointoken.mine(sigData[0], sigData[1], sigData[2], sigData[3], howManyEggs, {from: user1, value: price}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isTrue(error.toString().startsWith("Error: Returned error: VM Exception while processing transaction: revert Not Approved Nonce -- Reason given: Not Approved Nonce."), "Expected sending less than the price will yield nothing");
      });
      //replaying by another user fails
      await snekcointoken.mine(sigData[0], sigData[1], sigData[2], sigData[3], howManyEggs, {from: user2, value: 1000000}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isTrue(error.toString().startsWith("Error: Returned error: VM Exception while processing transaction: revert Not Approved User -- Reason given: Not Approved User."), "Expected sending less than the price will yield nothing");
      });
      // using the next nonce is okay

      let newtokensPerEgg = await snekcointoken.getMiningRate({from: user2});
      let newhowManyEggs = 1;
      let newprice = (newhowManyEggs * eggPrice.toNumber()) + miningPrice.toNumber();
      let newhowMany = newhowManyEggs*newtokensPerEgg.toNumber();
      let newsigData = await signAs(owner, user1Nonce+1, newhowMany, user1);

      await snekcointoken.mine(newsigData[0], newsigData[1], newsigData[2], newsigData[3], newhowManyEggs, {from: user1, value: newprice});
      var newNewUser1Balance = await snekcointoken.balanceOf(user1);
      assert.equal(newUser1Balance.toNumber() + newhowMany, newNewUser1Balance.toNumber(), "expected " + newhowMany + " more");
      // user1 nonce should increase by 2
      let user1NewNonce = await snekcointoken.getUserNonce.call(user1);
      assert.equal(user1Nonce.toNumber() + 2, user1NewNonce.toNumber(), "expected nonce + 2");
    });

    // it("snekcoin can be mined with snek", async function() {
    //   //let fakeUser = "0x0000000000000000000000000000000000000000000000000000000000000000000000000000"
    //   let fakeUserNonce = await snekcointoken.getUserNonce.call(fakeUser);
    //   let user1Nonce = await snekcointoken.getUserNonce.call(user1);
    //   let ownerBalance = await snekcointoken.balanceOf(owner);
    //   let user1Balance = await snekcointoken.balanceOf(user1);
    //   let totalSupply = await snekcointoken.totalSupply();
    //   let badSigPart = "0x0000000000000000000000000000000000000000000000000000000000000000";
    //   let sigData = await signAs(owner, user1Nonce, 1000, user1);
    //
    //   // price can only be changed by owner
    //   await snekcointoken.changeMiningSnekPrice(1, {from: user1}).then(() => {
    //     throw null;
    //   }).catch(function(error) {
    //     assert.isNotNull(error, "Expected unapproved revert");
    //   });
    //   // snek price can be changed
    //   await snekcointoken.changeMiningSnekPrice(10, {from: owner});
    //   var miningPrice = await snekcointoken.getMiningSnekPrice();
    //   assert.equal(miningPrice.toNumber(), 10, "expected 10");
    //   // mining must be pre-approved by owner
    //   await snekcointoken.mineWithSnek(sigData[0], sigData[1], badSigPart, sigData[3], 10, {from: user1}).then(() => {
    //     throw null;
    //   }).catch(function(error) {
    //     assert.isNotNull(error, "Expected unapproved revert badSigPart");
    //   });
    //   // sending less than the price will yield nothing
    //   await snekcointoken.mineWithSnek(sigData[0], sigData[1], sigData[2], sigData[3], 1, {from: user1, value: 10}).then(() => {
    //     throw null;
    //   }).catch(function(error) {
    //     assert.isNotNull(error, "Expected revert. not enough snek paid.");
    //   });
    //   // Sending enough snek succeeds
    //   await snekcointoken.mineWithSnek(sigData[0], sigData[1], sigData[2], sigData[3], 10, {from: user1});
    //   var newUser1Balance = await snekcointoken.balanceOf(user1);
    //   var newOwnerBalance = await snekcointoken.balanceOf(owner);
    //   assert.equal(user1Balance.toNumber() + 990, newUser1Balance.toNumber(), "expected 990 more");
    //   assert.equal(ownerBalance.toNumber() + 10, newOwnerBalance.toNumber(), "expected 10 more");
    //   //replaying fails
    //   await snekcointoken.mineWithSnek(sigData[0], sigData[1], sigData[2], sigData[3], 10, {from: user1}).then(() => {
    //     throw null;
    //   }).catch(function(error) {
    //     assert.isNotNull(error, "Expected revert replaying!!");
    //   });
    //
    //   // total supply should increase
    //   var newTotalSupply = await snekcointoken.totalSupply();
    //   assert.equal(totalSupply.toNumber() + 1000, newTotalSupply.toNumber(), "expected supply change");
    // });

    it("snekcoin cannot be mined without going through proper api", async function() {
      await fakesnekcointoken.mine.sendTransaction(user1, 1000, 1000000).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
      await fakesnekcointoken.mine(user1, 1000, 1000000, {from: owner, value: 777, gas: 100000}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
    });

    it("snekcoin total supply is limited logarithmically", async function() {
      var totalSupply1 = await snekcointoken.totalSupply({from: user2});
      let tokensPerEgg = await snekcointoken.getMiningRate({from: user2});
      assert.equal(tokensPerEgg, 512);

      var totalSupply2 = await snekcointoken2.totalSupply({from: user2});
      let tokensPerEgg2 = await snekcointoken2.getMiningRate({from: user2});
      assert.equal(tokensPerEgg2, 512);

      var totalSupply3 = await snekcointoken3.totalSupply({from: user2});
      let tokensPerEgg3 = await snekcointoken3.getMiningRate({from: user2});
      assert.equal(tokensPerEgg3, 1);

      var totalSupply4 = await snekcointoken4.totalSupply({from: user2});
      let tokensPerEgg4 = await snekcointoken4.getMiningRate({from: user2});
      assert.equal(tokensPerEgg4, 0);

    });
    // it('snekcointoken can be mined by owner for a user', async () => {
    //   // mining must be approved
    //   try {
    //     let foo = await snekcointoken.mineForUser(user1, 100, {from: user1})
    //     throw null;
    //   } catch (error) {
    //     assert.isNotNull(error, "Expected mineForUser revert");
    //   }
    //   let recpt = await snekcointoken.mineForUser(user1, 100, {from: owner})
    // });
    // it("test sender", async function() {
    //   var sender = await snekcointoken.getBackSender.call();
    //   var root = await snekcointoken.getRoot.call();
    //   console.log("***** START SENDER INFO *****");
    //   console.log(sender);
    //   console.log(snekcointoken.address);
    //   console.log(snekcoinback.address);
    //   console.log(root);
    //   console.log("***** END SENDER INFO *****");
    // });
    // it('measure gas costs', async () => {
    //   // https://ethgasstation.info/ 5.1Gwei
    //   var gasPriceWei = 5100000000;
    //   var dollarsPerEth = 250;
    //   var weiPerEth = 1000000000000000000;
    //   var gas = await snekcointoken.totalSupply.estimateGas({from: owner});
    //   // console.log("************** GAS ESTIMATES ************** ");
    //   // console.log("totalSupply esti: " + gas);
    //   // var ownerBalance = await snekcointoken.balanceOf(owner);
    //   // await snekcointoken.totalSupply.call({from: owner});
    //   // var newOwnerBalance = await snekcointoken.balanceOf(owner);
    //   // console.log("totalSupply real: " + (ownerBalance - newOwnerBalance));
    //   // console.log("totalSupply price: " + gas*gasPriceWei*dollarsPerEth/weiPerEth);
    //   // gas = await snekcointoken.mine.estimateGas(user1, 1000, 1000000, {from: owner, value: 777, gas: 100000});
    //   // console.log("mine esti: " + gas);
    //   // var ownerBalance = await snekcointoken.balanceOf(owner);
    //   // await snekcointoken.mine.call(user1, 1000, 1000000, {from: owner, value: 777, gas: 100000});
    //   // var newOwnerBalance = await snekcointoken.balanceOf(owner);
    //   // console.log("mine real: " + (ownerBalance - newOwnerBalance));
    //   // console.log("mine price: " + gas*gasPriceWei*dollarsPerEth/weiPerEth);
    //   // await snekcointoken.mine(user1, 1000, 1000000, {from: owner, value: 777, gas: 100000});
    //   // console.log("************** GAS ESTIMATES ************** ");
    // });
  });

});
