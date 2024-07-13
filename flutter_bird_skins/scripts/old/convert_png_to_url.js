const fs = require('fs');
const path = require('path');

function convertPngToBase64DataUrl(tokenId) {
    const outputDirectory = "../output/images";
    const filePath = path.join(outputDirectory, `${tokenId}.png`);

    if (!fs.existsSync(filePath)) {
        console.error(`File not found: ${filePath}`);
        return null;
    }

    const fileData = fs.readFileSync(filePath);

    const base64Data = fileData.toString('base64');

    const dataUrl = `data:image/png;base64,${base64Data}`;

    return dataUrl;
}

const tokenId = 0;
const dataUrl = convertPngToBase64DataUrl(tokenId);

if (dataUrl) {
    console.log(`Data URL for token ${tokenId}:`);
    console.log(dataUrl.substring(0, 100) + '...');

    fs.writeFileSync(`../output/dataUrls/${tokenId}_dataUrl.txt`, dataUrl);
}
