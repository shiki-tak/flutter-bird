require('dotenv').config();
const HDWalletProvider = require("truffle-hdwallet-provider-klaytn");

module.exports = {
    networks: {
        development: {
            host: "127.0.0.1",
            port: 7545,
            network_id: "*",
        },

        baobab: {
            provider: () => {
              return new HDWalletProvider(process.env.PRIVATE_KEY, "https://public-en-baobab.klaytn.net");
            },
            network_id: "1001", //Klaytn baobab testnet's network id
            gas: "8500000",
            gasPrice: null,
          },


    },

    compilers: {
        solc: {
            version: "0.8.14",
        }
    },

    plugins: [
        'truffle-plugin-verify'
    ],
};
