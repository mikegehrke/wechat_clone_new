const express = require('express');
const router = express.Router();

router.get('/games', async (req, res) => {
  res.json({ games: [] });
});

module.exports = router;