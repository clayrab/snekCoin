require('babel-polyfill');

module.exports = {
  networks: {
    sample: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*" // Match any network id
    }
  }
};
