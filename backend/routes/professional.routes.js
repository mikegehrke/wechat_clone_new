const express = require('express');
const router = express.Router();

router.get('/professionals', async (req, res) => {
  res.json({ professionals: [] });
});

module.exports = router;