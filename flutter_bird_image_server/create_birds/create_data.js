const {generateImage} = require("./generate_image")
const {generateMetadata} = require("./generate_metadata")


async function mintRandomSkin(tokenId) {
    try {
        // Generate random metadata
        const skinMetadata = generateMetadata(tokenId)

        // Create image from metadata
        await generateImage(
            tokenId,
            skinMetadata.attributes[0]['value'],
            skinMetadata.attributes[1]['value'],
            skinMetadata.attributes[2]['value'],
            skinMetadata.attributes[3]['value'],
            skinMetadata.attributes[4]['value'],
        )
    } catch (e) {
        console.error('Error in mintRandomSkin:', e);
        throw e;
    }
}

module.exports = {mintRandomSkin};

