const express = require('express');
const router = express.Router();

router.get('/streams', async (req, res) => {
  res.json({ streams: [] });
});

module.exports = router;