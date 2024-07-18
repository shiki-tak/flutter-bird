const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const { mintRandomSkin } = require("./create_birds/create_data")

const app = express();
const port = process.env.PORT || 3000;

app.use(cors({
  origin: '*',
  credentials: true,
  optionsSuccessStatus: 200
}))

app.get('/image/:tokenId', async (req, res) => {
  try {
    const tokenId = req.params.tokenId;
    const filename = tokenId + ".png";
  
    const imagePath = path.join(__dirname, 'output', 'images', filename);
    console.log(`imagePath: ${imagePath}`);
    
    if (fs.existsSync(imagePath)) {
      res.sendFile(imagePath);
    } else {
      await mintRandomSkin(tokenId);
      if (fs.existsSync(imagePath)) {
        res.sendFile(imagePath);
      } else {
        throw new Error('Failed to generate image');
      }
    }
  } catch(e) {
    console.error('Error in /image/:tokenId route:', e);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.get('/', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Server is running' });
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
