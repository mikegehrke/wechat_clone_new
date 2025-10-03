const express = require('express');
const router = express.Router();
const multer = require('multer');
const { authenticate } = require('../middleware/auth.middleware');

const upload = multer({ 
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB
  storage: multer.memoryStorage()
});

router.post('/upload', authenticate, upload.single('file'), async (req, res) => {
  res.json({ url: 'https://placeholder.com/file.jpg' });
});

module.exports = router;