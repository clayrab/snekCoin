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

contract('TestProxyLibrary', (accounts) => {
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
  let fakesnekcointoken;

  let exampleVersion1;
  let exampleVersion2;
  let exampleDispatcherStorage;
  let exampleDispatcher;

  let thecontract;
  describe('test', () => {
    before(async function() {

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
      snekcoinback = await SnekCoinBack.new("TestContract", 20, 1000000);
      snekcointoken = await SnekCoinToken.new(snekcoinback.address);
      snekcoinback.setRoot(snekcointoken.address);
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

    });


    // function setOwner(address newOwner)
    // public onlyBy(owner, s.root) returns(bool){
    //   s.owner = newOwner;
    // }
    // function getOwner()
    // public view returns(address){
    //   return s.owner;
    // }
    it('versioning', async () => {
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
      assert.equal(1000000, totalSupply.toNumber(), "expected supply of 1000000");
      // break it!
      await dispatcherStorage.replace(snek00x.address);
      totalSupply = await snekcointoken.totalSupply.call();
      assert.equal(totalSupply.toNumber(), 1000000 * 10, "expected supply to be 10x");
      // REALLY BREAK IT!!
      await dispatcherStorage.replace(0x0);
      snekcointoken.totalSupply.call().then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
      // And put it back to normal...
      await dispatcherStorage.replace(snek001.address);
      totalSupply = await snekcointoken.totalSupply.call();
      assert.equal(1000000, totalSupply.toNumber(), "expected supply of 1000000");
    });

    it("snekcoin root should be SnekCoin", async function() {
      var root = await snekcointoken.getRoot.call();
      assert.equal(snekcointoken.address, root, "expected adddress of root to be snekcoin");
    });
    it("snekcoin should have total supply 1000000", async function() {
      var totalSupply = await snekcointoken.totalSupply.call();
      assert.equal(1000000, totalSupply.toNumber(), "expected supply of 1000000");
    });
    it("snekcoin owner should have total supply", async function() {
      var totalSupply = await snekcointoken.totalSupply.call();
      var ownerBalance = await snekcointoken.balanceOf(owner);
      assert.equal(ownerBalance.toNumber(), totalSupply.toNumber(), "expected owner to have supply");
    });

    it("snekcoin can be transferred", async function() {
      var ownerBalance = await snekcointoken.balanceOf(owner);
      var user1Balance = await snekcointoken.balanceOf(user1);
      await snekcointoken.transfer(user1, 10, {from: owner});
      var newOwnerBalance = await snekcointoken.balanceOf(owner);
      //console.log(out.toNumber());
      var newUser1Balance = await snekcointoken.balanceOf(user1);
      assert.equal(newOwnerBalance.toNumber(), ownerBalance.toNumber() - 10, "");
      assert.equal(newUser1Balance.toNumber(), user1Balance.toNumber() + 10, "");
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
      await web3.eth.sendTransaction({from: owner, to: snekcointoken.address, value: web3.toWei(0.000003, "ether"), gas: 200000 });
      var endEth = await snekcointoken.getBalance.call();
      var ownerEndEth = web3.eth.getBalance(owner);
      assert.equal(startEth.toNumber(), endEth.toNumber() - web3.toWei(0.000003, "ether"), "expected eth to move");
      //can withdraw
      startEth = await snekcointoken.getBalance.call();
      await snekcointoken.withdraw(web3.toWei(0.000001, "ether"), {from: owner});
      endEth = await snekcointoken.getBalance.call();
      assert.equal(startEth.toNumber(), endEth.toNumber() + 1000000000000, "expected eth to move");
      // only owner can withdraw
      snekcointoken.withdraw(web3.toWei(0.000001, "ether"), {from: user1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "withdraw expected revert, but got none");
      });
      // owner cannot draw more than is available
      // snekcointoken.withdraw(web3.toWei(0.001, "ether"), {from: owner}).then(() => {
      //   throw null;
      // }).catch(function(error) {
      //   assert.isNotNull(error, "withdrawal expected revert, but got none");
      // });
    });

    it("snekcoin can be mined", async function() {
      var user1Balance = await snekcointoken.balanceOf(user1);
      var totalSupply = await snekcointoken.totalSupply();
      // price can be changed
      await snekcointoken.changeMiningPrice(1000000, {from: owner});
      var miningPrice = await snekcointoken.getMiningPrice();
      assert.equal(miningPrice.toNumber(), 1000000, "expected 1000000");
      //// price can only be changed by owner
      await snekcointoken.changeMiningPrice(1, {from: user1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected unapproved revert");
      });
      // mining must be pre-approved by owner
      await snekcointoken.mine(1000, {from: user1, value: 1000000}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected unapproved revert");
      });
      // must be approved by owner...
      await snekcointoken.approveMine(user1, 1000, {from: user1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected user1 can't approve");
      });
      // approving...
      await snekcointoken.approveMine(user1, 1000, {from: owner});
      var approvedAmount = await snekcointoken.isMineApproved(user1, {from: user1});
      assert.equal(approvedAmount.toNumber(), 1000, "expected 1000");
      // sending less than the price will yield nothing
      await snekcointoken.mine(1000, {from: user1, value: 10}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
      // attempting to mine more than approved will yield nothing
      await snekcointoken.mine(3000, {from: user1, value: 1000000}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
      // Sending enough wei succeeds
      await snekcointoken.mine(1000, {from: user1, value: 1000000});
      var newUser1Balance = await snekcointoken.balanceOf(user1);
      assert.equal(user1Balance.toNumber() + 1000, newUser1Balance.toNumber(), "expected 1000 more");
      // No more approval left
      await snekcointoken.mine(1, {from: user1, value: 1000000}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none!!");
      });
      var newNewUser1Balance = await snekcointoken.balanceOf(user1);
      assert.equal(newNewUser1Balance.toNumber(), newUser1Balance.toNumber(), "expected no change");
      // total supply should increase
      var newTotalSupply = await snekcointoken.totalSupply();
      assert.equal(totalSupply.toNumber() + 1000, newTotalSupply.toNumber(), "expected supply change");
    });

    it("snekcoin can be mined with snek", async function() {
      var ownerBalance = await snekcointoken.balanceOf(owner);
      var user1Balance = await snekcointoken.balanceOf(user1);
      var totalSupply = await snekcointoken.totalSupply();
      // price can only be changed by owner
      await snekcointoken.changeMiningSnekPrice(1, {from: user1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected unapproved revert");
      });
      // snek price can be changed
      await snekcointoken.changeMiningSnekPrice(10, {from: owner});
      var miningPrice = await snekcointoken.getMiningSnekPrice();
      assert.equal(miningPrice.toNumber(), 10, "expected 10");
      // mining must be pre-approved by owner
      await snekcointoken.mineWithSnek(1000, 10, {from: user1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected unapproved revert");
      });
      // approving...
      await snekcointoken.approveMine(user1, 2000, {from: owner});
      var approvedAmount = await snekcointoken.isMineApproved(user1, {from: user1});
      assert.equal(approvedAmount.toNumber(), 2000, "expected 2000");
      // sending less than the price will yield nothing
      await snekcointoken.mineWithSnek(2000, 1, {from: user1, value: 10}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
      // mining more than approved will yield nothing
      await snekcointoken.mineWithSnek(3000, 10, {from: user1, value: 10}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
      // Sending enough snek succeeds
      await snekcointoken.mineWithSnek(2000, 10, {from: user1});
      var newUser1Balance = await snekcointoken.balanceOf(user1);
      var newOwnerBalance = await snekcointoken.balanceOf(owner);
      assert.equal(user1Balance.toNumber() + 1990, newUser1Balance.toNumber(), "expected 1990 more");
      assert.equal(ownerBalance.toNumber() + 10, newOwnerBalance.toNumber(), "expected 10 more");

      // No more approval left
      await snekcointoken.mineWithSnek(1, 10, {from: user1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none!!");
      });
      // total supply should increase
      var newTotalSupply = await snekcointoken.totalSupply();
      assert.equal(totalSupply.toNumber() + 2000, newTotalSupply.toNumber(), "expected supply change");
    });
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

    it("test sender", async function() {
      var sender = await snekcointoken.getSender.call();
      var root = await snekcointoken.getRoot.call();
      // console.log("***** START SENDER INFO *****");
      // console.log(sender);
      // console.log(snekcointoken.address);
      // console.log(snekcoinback.address);
      // console.log(root);
      // console.log("***** END SENDER INFO *****");
    });
    it('measure gas costs', async () => {
      // https://ethgasstation.info/ 5.1Gwei
      var gasPriceWei = 5100000000;
      var dollarsPerEth = 250;
      var weiPerEth = 1000000000000000000;
      var gas = await snekcointoken.totalSupply.estimateGas({from: owner});
      // console.log("************** GAS ESTIMATES ************** ");
      // console.log("totalSupply esti: " + gas);
      // var ownerBalance = await snekcointoken.balanceOf(owner);
      // await snekcointoken.totalSupply.call({from: owner});
      // var newOwnerBalance = await snekcointoken.balanceOf(owner);
      // console.log("totalSupply real: " + (ownerBalance - newOwnerBalance));
      // console.log("totalSupply price: " + gas*gasPriceWei*dollarsPerEth/weiPerEth);
      // gas = await snekcointoken.mine.estimateGas(user1, 1000, 1000000, {from: owner, value: 777, gas: 100000});
      // console.log("mine esti: " + gas);
      // var ownerBalance = await snekcointoken.balanceOf(owner);
      // await snekcointoken.mine.call(user1, 1000, 1000000, {from: owner, value: 777, gas: 100000});
      // var newOwnerBalance = await snekcointoken.balanceOf(owner);
      // console.log("mine real: " + (ownerBalance - newOwnerBalance));
      // console.log("mine price: " + gas*gasPriceWei*dollarsPerEth/weiPerEth);
      // await snekcointoken.mine(user1, 1000, 1000000, {from: owner, value: 777, gas: 100000});
      // console.log("************** GAS ESTIMATES ************** ");
    });
  });
});
