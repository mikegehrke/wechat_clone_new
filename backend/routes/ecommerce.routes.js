const express = require('express');
const router = express.Router();
const { authenticate, optionalAuth } = require('../middleware/auth.middleware');

// Get products
router.get('/products', optionalAuth, async (req, res) => {
  res.json({ products: [] });
});

// Get cart
router.get('/cart', authenticate, async (req, res) => {
  res.json({ cart: { items: [] } });
});

module.exports = router;