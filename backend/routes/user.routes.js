const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');

// Simplified user routes for now
router.get('/profile', authenticate, async (req, res) => {
  try {
    res.json({ user: req.user });
  } catch (error) {
    res.status(500).json({ error: 'Failed to get profile' });
  }
});

router.put('/profile', authenticate, async (req, res) => {
  try {
    const updates = req.body;
    Object.assign(req.user, updates);
    await req.user.save();
    res.json({ user: req.user });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

module.exports = router;