const { splitData } = require('../lib/split_data');
const { waitTx } = require('../lib/common');

async function uploadUri(contract, tokenId, uri, splitSize) {
  const data = Buffer.from(uri);
  const chunkValues = splitData(data, splitSize, 5);
  let totalGasUsed = 0;
  console.log('chunk count:', chunkValues.length);
  for (let i = 0; i < chunkValues.length; i++) {
    const values = chunkValues[i];
    const tx = await contract.appendUri(tokenId, values);
    console.log(`appendUri tx: ${tx}`);
  }
}

module.exports = {
  uploadUri
};
