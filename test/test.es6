'use strict';

const Dispatcher = artifacts.require('Dispatcher.sol');
const DispatcherStorage = artifacts.require('DispatcherStorage.sol');
const SnekCoin = artifacts.require('SnekCoin.sol');
const SnekCoin0_0_1 = artifacts.require('SnekCoin0_0_1.sol');
const SnekCoin0_0_X = artifacts.require('./SnekCoin0_0_X.sol');

const TheContract = artifacts.require('./TheContract.sol');
const ExampleVersion1 = artifacts.require('./Example.sol');
const ExampleReverts = artifacts.require('./ExampleReverts.sol');
const ExampleVersion2 = artifacts.require('./ExampleVersion2.sol');

contract('TestProxyLibrary', (accounts) => {
  let snekCoin;
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
  let snekcoin;

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
      // Dispatcher.unlinked_binary = Dispatcher.unlinked_binary
      //     .replace('1111222233334444555566667777888899990000',
      //         dispatcherStorage.address.slice(2));
      Dispatcher.unlinked_binary = Dispatcher.unlinked_binary
          .replace(exampleDispatcherStorage.address.slice(2),
              dispatcherStorage.address.slice(2));
      dispatcher = await Dispatcher.new();
      SnekCoin.link('LibInterface', dispatcher.address);
      snekcoin = await SnekCoin.new("TestContract", 20, 1000000);

    });

    it('versioning works', async () => {
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
    it('measure gas costs', (done) => {
      done();
    });

    context('only owner can call', () => {
      let example, example2, dispatcherStorage, subject
      beforeEach(async () => {
        example = await ExampleVersion1.new();
        example2 = await ExampleVersion2.new();
        exampleDispatcherStorage = await DispatcherStorage.new(example.address, {from: accounts[0]});
        subject = (account) => exampleDispatcherStorage.replace(example2.address, {from: account});
      })

      it('fail', async () => {
        subject(accounts[1]).then(() => {
          throw null;
        }).catch(function(error) {
          assert.isNotNull(error, "Expected revert, but got none");
        });
      });
      it('success', async () => {
        const result = await subject(accounts[0])
        assert.isOk(result)
      });
    });

    it("snekcoin can be updated", async function() {
      var totalSupply = await snekcoin.totalSupply.call();
      assert.equal(1000000, totalSupply.toNumber(), "expected supply of 1000000");
      // break it!
      await dispatcherStorage.replace(snek00x.address);
      totalSupply = await snekcoin.totalSupply.call();
      assert.equal(totalSupply.toNumber(), 1000000 * 10, "expected supply to be 10x");
      // REALLY BREAK IT!!
      await dispatcherStorage.replace(0x0);
      snekcoin.totalSupply.call().then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
      // And put it back to normal...
      await dispatcherStorage.replace(snek001.address);
      totalSupply = await snekcoin.totalSupply.call();
      assert.equal(1000000, totalSupply.toNumber(), "expected supply of 1000000");
    });
    it("snekcoin should have total supply 1000000", async function() {
      var totalSupply = await snekcoin.totalSupply.call();
      assert.equal(1000000, totalSupply.toNumber(), "expected supply of 1000000");
    });
    it("snekcoin root should be SnekCoin", async function() {
      var root = await snekcoin.getRoot.call();
      assert.equal(snekcoin.address, root, "expected adddress of root to be snekcoin");
    });
    it("snekcoin can receive and send eth", async function() {
      // can receive
      var startEth = await snekcoin.getBalance.call();
      var ownerStartEth = web3.eth.getBalance(owner);
      await web3.eth.sendTransaction({from: owner, to: snekcoin.address, value:  web3.toWei(0.000003, "ether"), gas: 200000 });
      var endEth = await snekcoin.getBalance.call();
      var ownerEndEth = web3.eth.getBalance(owner);
      assert.equal(startEth.toNumber(), endEth.toNumber() -  web3.toWei(0.000003, "ether"), "expected eth to move");
      //can withdraw
      startEth = await snekcoin.getBalance.call();
      await snekcoin.withdraw(web3.toWei(0.000001, "ether"), {from: owner});
      endEth = await snekcoin.getBalance.call();
      assert.equal(startEth.toNumber(), endEth.toNumber() + 1000000000000, "expected eth to move");
      // only owner can withdraw
      snekcoin.withdraw(web3.toWei(0.000001, "ether"), {from: user1}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
      // owner cannot draw more than is available
      snekcoin.withdraw(web3.toWei(0.001, "ether"), {from: owner}).then(() => {
        throw null;
      }).catch(function(error) {
        assert.isNotNull(error, "Expected revert, but got none");
      });
    });

    it("snekcoin can be counted", async function() {
      var ownerBalance = await snekcoin.balanceOf(owner);
      var user1Balance = await snekcoin.balanceOf(user1);
      await snekcoin.transfer(user1, 10, {from: owner});
      var newOwnerBalance = await snekcoin.balanceOf(owner);
      var newUser1Balance = await snekcoin.balanceOf(user1);
      assert.equal(newOwnerBalance.toNumber(), ownerBalance.toNumber() - 10, "");
      assert.equal(newUser1Balance.toNumber(), user1Balance.toNumber() + 10, "");
    });

    it("snekcoin can be transferred through allowanance", async function() {
      var ownerBalance = await snekcoin.balanceOf(owner);
      var user2Balance = await snekcoin.balanceOf(user2);
      var status = await snekcoin.approve(user1, 2, {from: owner});
      var allowance = await snekcoin.allowance(owner, user1, {from: owner});
      assert.equal(allowance.toNumber(), 2, "");
      var status = await snekcoin.transferFrom(owner, user2, 1, {from: user1});
      var newOwnerBalance = await snekcoin.balanceOf(owner);
      var newUser2Balance = await snekcoin.balanceOf(user2);
      assert.equal(newOwnerBalance.toNumber(), ownerBalance.toNumber() - 1, "");
      assert.equal(newUser2Balance.toNumber(), user2Balance.toNumber() + 1, "");
    });


  });
});
