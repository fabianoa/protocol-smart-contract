// Allows us to use ES6 in our migrations and tests.
require('babel-register')

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*' // Match any network id
    },
    dtp: {
      host: 'n461d0116e00362-ext.nuvemdtp',
      port: 8080,
      network_id: '*' // Match any network id
    },vm: {
      host: '192.168.25.52',
      port: 8545,
      network_id: '*' // Match any network id
    }

  }
}
