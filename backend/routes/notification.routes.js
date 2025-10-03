const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');

router.get('/', authenticate, async (req, res) => {
  res.json({ notifications: [] });
});

module.exports = router;