const express = require('express');
const router = express.Router();
const { body } = require('express-validator');
const authController = require('../controllers/auth.controller');
const { authenticate } = require('../middleware/auth.middleware');

// Validation rules
const phoneValidation = body('phoneNumber')
  .matches(/^\+?[1-9]\d{1,14}$/)
  .withMessage('Invalid phone number format');

const emailValidation = body('email')
  .isEmail()
  .normalizeEmail()
  .withMessage('Invalid email format');

const passwordValidation = body('password')
  .isLength({ min: 8 })
  .withMessage('Password must be at least 8 characters')
  .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
  .withMessage('Password must contain uppercase, lowercase, and number');

const usernameValidation = body('username')
  .isLength({ min: 3, max: 30 })
  .matches(/^[a-zA-Z0-9_]+$/)
  .withMessage('Username can only contain letters, numbers, and underscores');

// Routes

// Register with phone
router.post('/register/phone',
  [
    phoneValidation,
    usernameValidation,
    body('displayName').notEmpty().withMessage('Display name is required')
  ],
  authController.registerWithPhone
);

// Verify OTP and complete registration
router.post('/verify-otp',
  [
    phoneValidation,
    body('otp').isLength({ min: 6, max: 6 }).withMessage('OTP must be 6 digits'),
    passwordValidation
  ],
  authController.verifyOTP
);

// Login with phone
router.post('/login/phone',
  [
    phoneValidation,
    body('password').notEmpty().withMessage('Password is required')
  ],
  authController.loginWithPhone
);

// Login with email
router.post('/login/email',
  [
    emailValidation,
    body('password').notEmpty().withMessage('Password is required')
  ],
  authController.loginWithEmail
);

// Social login
router.post('/login/social',
  [
    body('provider').isIn(['google', 'facebook', 'apple', 'twitter']).withMessage('Invalid provider'),
    body('providerId').notEmpty().withMessage('Provider ID is required')
  ],
  authController.socialLogin
);

// Refresh token
router.post('/refresh',
  body('refreshToken').notEmpty().withMessage('Refresh token is required'),
  authController.refreshToken
);

// Send OTP
router.post('/send-otp',
  phoneValidation,
  authController.sendOTP
);

// Forgot password
router.post('/forgot-password',
  emailValidation,
  authController.forgotPassword
);

// Reset password
router.post('/reset-password',
  [
    body('token').notEmpty().withMessage('Reset token is required'),
    passwordValidation
  ],
  authController.resetPassword
);

// Protected routes (require authentication)

// Logout
router.post('/logout',
  authenticate,
  authController.logout
);

// Change password
router.post('/change-password',
  authenticate,
  [
    body('currentPassword').notEmpty().withMessage('Current password is required'),
    passwordValidation.withMessage('New password validation failed')
  ],
  authController.changePassword
);

// Delete account
router.delete('/account',
  authenticate,
  body('password').notEmpty().withMessage('Password is required'),
  authController.deleteAccount
);

module.exports = router;