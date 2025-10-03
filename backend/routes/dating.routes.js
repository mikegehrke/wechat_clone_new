const express = require('express');
const router = express.Router();

router.get('/profiles', async (req, res) => {
  res.json({ profiles: [] });
});

module.exports = router;