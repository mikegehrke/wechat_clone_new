const express = require('express');
const router = express.Router();

router.get('/restaurants', async (req, res) => {
  res.json({ restaurants: [] });
});

module.exports = router;