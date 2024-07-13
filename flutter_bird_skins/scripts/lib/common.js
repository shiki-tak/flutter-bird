const Web3 = require('web3');
const web3 = new Web3(Web3.givenProvider || 'http://localhost:9545');

const getEnvValue = (key) => {
  const value = process.env[key];
  console.log(key + ' is:', value);
  if (value === undefined) throw Error(key + ' is undefined');
  if (value === '') throw Error(key + ' is empty');
  return value;
};

const getEnvValueAsBoolean = (key) => {
  const value = getEnvValue(key);
  if (value === 'true') return true;
  if (value === 'false') return false;
  throw Error(key + ' is invalid');
};

const getEnvValueAsNumber = (key) => {
  const value = getEnvValue(key);
  const num = Number(value);
  if (Number.isNaN(num)) throw Error(key + ' is invalid');
  return num;
};

function toGwei(gasPrice) {
  if (gasPrice === undefined) return 'undefined';
  return web3.utils.fromWei(gasPrice, 'gwei') + ' gwei';
}

const waitDeployed = async (title, contract) => {
  console.log('# Deploy ' + title);
  console.log('contract deploy to:', contract.address);
  const receipt = await web3.eth.getTransactionReceipt(contract.transactionHash);
  console.log('hash:', receipt.transactionHash);
  console.log('gasPrice:', toGwei(receipt.gasPrice));
  console.log('deployed!');
  console.log();
};

const waitTx = async (title, tx) => {
  console.log('# ' + title);
  console.log('hash:', tx.transactionHash);
  const transaction = await web3.eth.getTransaction(tx.transactionHash);
  console.log('gasPrice:', toGwei(transaction.gasPrice));
  console.log('nonce', transaction.nonce);
  const receipt = await web3.eth.getTransactionReceipt(tx.transactionHash);
  console.log('gasUsed:', receipt.gasUsed.toString());
  console.log('confirmed!');
  console.log();
  return parseInt(receipt.gasUsed);
};

function showGas(title, gas) {
  console.log(`${title}: gas=${gas.toString()}`);
}

module.exports = {
  getEnvValue,
  getEnvValueAsBoolean,
  getEnvValueAsNumber,
  toGwei,
  waitDeployed,
  waitTx,
  showGas
};
