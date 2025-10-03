const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');

// Placeholder payment routes
router.get('/methods', authenticate, async (req, res) => {
  res.json({ methods: [] });
});

router.post('/charge', authenticate, async (req, res) => {
  res.json({ success: true, transactionId: 'txn_' + Date.now() });
});

module.exports = router;