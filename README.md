Ethereum ERC20 which powers the backend of <a href="blockchainbridge.io>"Blockchain Bridge</a>

The implementation of this coin can be upgraded by the owner by leveraging the delegatecall EVM instruction which was added in Byzantium. This type of behavior is not needed for most public blockchain projects but may be useful for Enterprises which have legal obligations to their users but who would still like to wrap their digital asset in an ERC20 token.

For more information on delegatecall, see this medium post:

https://medium.com/coinmonks/delegatecall-calling-another-contract-function-in-solidity-b579f804178c

