Ethereum ERC20 which powers the backend of [Blockchain Bridge](blockchainbridge.io).

The implementation of this coin can be upgraded by the owner by leveraging the delegatecall EVM instruction which was added in Byzantium. This type of behavior is not needed for most public blockchain projects but may be useful for Enterprises which have legal obligations to their users, enabling them to wrap a digital asset into a token while still maintaining complete control of the coin in case they must change the implementation or even revoke coins from users.

For more information on delegatecall, see this medium post:

https://medium.com/coinmonks/delegatecall-calling-another-contract-function-in-solidity-b579f804178c

