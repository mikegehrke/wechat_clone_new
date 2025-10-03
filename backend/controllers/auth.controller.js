const User = require('../models/User.model');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const { validationResult } = require('express-validator');
const twilioService = require('../services/twilio.service');
const emailService = require('../services/email.service');
const redisClient = require('../utils/redis');

// Generate OTP
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// Register with phone number
exports.registerWithPhone = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { phoneNumber, username, displayName } = req.body;

    // Check if phone number already exists
    const existingUser = await User.findOne({ 
      $or: [{ phoneNumber }, { username }] 
    });
    
    if (existingUser) {
      return res.status(409).json({
        error: 'Phone number or username already registered'
      });
    }

    // Generate and send OTP
    const otp = generateOTP();
    
    // Store OTP in Redis with 10 minute expiry
    await redisClient.setex(`otp:${phoneNumber}`, 600, otp);
    
    // Send OTP via SMS
    await twilioService.sendSMS(phoneNumber, `Your verification code is: ${otp}`);

    // Store registration data temporarily
    await redisClient.setex(
      `registration:${phoneNumber}`,
      600,
      JSON.stringify({ phoneNumber, username, displayName })
    );

    res.status(200).json({
      message: 'OTP sent successfully',
      phoneNumber
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Registration failed' });
  }
};

// Verify OTP and complete registration
exports.verifyOTP = async (req, res) => {
  try {
    const { phoneNumber, otp, password } = req.body;

    // Get stored OTP
    const storedOTP = await redisClient.get(`otp:${phoneNumber}`);
    
    if (!storedOTP || storedOTP !== otp) {
      return res.status(400).json({ error: 'Invalid or expired OTP' });
    }

    // Get registration data
    const registrationData = await redisClient.get(`registration:${phoneNumber}`);
    
    if (!registrationData) {
      return res.status(400).json({ error: 'Registration session expired' });
    }

    const userData = JSON.parse(registrationData);

    // Create user
    const user = new User({
      ...userData,
      password,
      isVerified: true
    });

    await user.save();

    // Generate tokens
    const accessToken = user.generateAuthToken();
    const refreshToken = user.generateRefreshToken();

    // Save refresh token
    user.refreshToken = refreshToken;
    user.lastLogin = new Date();
    await user.save();

    // Clean up Redis
    await redisClient.del(`otp:${phoneNumber}`);
    await redisClient.del(`registration:${phoneNumber}`);

    res.status(201).json({
      message: 'Registration successful',
      user: user.toJSON(),
      tokens: {
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    console.error('OTP verification error:', error);
    res.status(500).json({ error: 'Verification failed' });
  }
};

// Login with phone
exports.loginWithPhone = async (req, res) => {
  try {
    const { phoneNumber, password } = req.body;

    // Find user and include password
    const user = await User.findOne({ phoneNumber }).select('+password');
    
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check if account is locked
    if (user.isLocked()) {
      return res.status(423).json({ error: 'Account is locked. Please try again later.' });
    }

    // Verify password
    const isPasswordValid = await user.comparePassword(password);
    
    if (!isPasswordValid) {
      await user.incLoginAttempts();
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check if account is active
    if (!user.isActive) {
      return res.status(403).json({ error: 'Account is deactivated' });
    }

    if (user.isBanned) {
      return res.status(403).json({ error: 'Account is banned' });
    }

    // Reset login attempts
    await user.resetLoginAttempts();

    // Generate tokens
    const accessToken = user.generateAuthToken();
    const refreshToken = user.generateRefreshToken();

    // Update user
    user.refreshToken = refreshToken;
    user.lastLogin = new Date();
    await user.save();

    res.status(200).json({
      message: 'Login successful',
      user: user.toJSON(),
      tokens: {
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
};

// Login with email
exports.loginWithEmail = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find user and include password
    const user = await User.findOne({ email: email.toLowerCase() }).select('+password');
    
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check if account is locked
    if (user.isLocked()) {
      return res.status(423).json({ error: 'Account is locked. Please try again later.' });
    }

    // Verify password
    const isPasswordValid = await user.comparePassword(password);
    
    if (!isPasswordValid) {
      await user.incLoginAttempts();
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Check if account is active
    if (!user.isActive) {
      return res.status(403).json({ error: 'Account is deactivated' });
    }

    if (user.isBanned) {
      return res.status(403).json({ error: 'Account is banned' });
    }

    // Reset login attempts
    await user.resetLoginAttempts();

    // Generate tokens
    const accessToken = user.generateAuthToken();
    const refreshToken = user.generateRefreshToken();

    // Update user
    user.refreshToken = refreshToken;
    user.lastLogin = new Date();
    await user.save();

    res.status(200).json({
      message: 'Login successful',
      user: user.toJSON(),
      tokens: {
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
};

// Social login
exports.socialLogin = async (req, res) => {
  try {
    const { provider, providerId, email, name, avatar } = req.body;

    // Find user with social login
    let user = await User.findOne({
      'socialLogins.provider': provider,
      'socialLogins.providerId': providerId
    });

    if (!user && email) {
      // Check if user exists with email
      user = await User.findOne({ email: email.toLowerCase() });
      
      if (user) {
        // Add social login to existing user
        user.socialLogins.push({
          provider,
          providerId,
          email,
          avatar
        });
      }
    }

    if (!user) {
      // Create new user
      const username = email ? email.split('@')[0] : `user_${providerId.substring(0, 8)}`;
      
      user = new User({
        email: email?.toLowerCase(),
        username: `${username}_${Date.now()}`, // Ensure unique username
        displayName: name || username,
        avatar: { url: avatar },
        isVerified: true,
        socialLogins: [{
          provider,
          providerId,
          email,
          avatar
        }]
      });
    }

    // Generate tokens
    const accessToken = user.generateAuthToken();
    const refreshToken = user.generateRefreshToken();

    // Update user
    user.refreshToken = refreshToken;
    user.lastLogin = new Date();
    await user.save();

    res.status(200).json({
      message: 'Login successful',
      user: user.toJSON(),
      tokens: {
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    console.error('Social login error:', error);
    res.status(500).json({ error: 'Social login failed' });
  }
};

// Refresh token
exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ error: 'Refresh token required' });
    }

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.REFRESH_TOKEN_SECRET);
    
    // Find user
    const user = await User.findById(decoded.id);
    
    if (!user || user.refreshToken !== refreshToken) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    // Generate new tokens
    const newAccessToken = user.generateAuthToken();
    const newRefreshToken = user.generateRefreshToken();

    // Update refresh token
    user.refreshToken = newRefreshToken;
    await user.save();

    res.status(200).json({
      tokens: {
        accessToken: newAccessToken,
        refreshToken: newRefreshToken
      }
    });
  } catch (error) {
    console.error('Token refresh error:', error);
    res.status(401).json({ error: 'Token refresh failed' });
  }
};

// Logout
exports.logout = async (req, res) => {
  try {
    const user = req.user;
    
    // Remove refresh token
    user.refreshToken = null;
    await user.save();

    res.status(200).json({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({ error: 'Logout failed' });
  }
};

// Send OTP
exports.sendOTP = async (req, res) => {
  try {
    const { phoneNumber } = req.body;

    // Generate OTP
    const otp = generateOTP();
    
    // Store OTP in Redis with 10 minute expiry
    await redisClient.setex(`otp:${phoneNumber}`, 600, otp);
    
    // Send OTP via SMS
    await twilioService.sendSMS(phoneNumber, `Your verification code is: ${otp}`);

    res.status(200).json({
      message: 'OTP sent successfully',
      phoneNumber
    });
  } catch (error) {
    console.error('Send OTP error:', error);
    res.status(500).json({ error: 'Failed to send OTP' });
  }
};

// Forgot password
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email: email.toLowerCase() });
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Generate reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const hashedToken = crypto
      .createHash('sha256')
      .update(resetToken)
      .digest('hex');

    // Save reset token
    user.resetPasswordToken = hashedToken;
    user.resetPasswordExpiry = Date.now() + 3600000; // 1 hour
    await user.save();

    // Send email
    const resetUrl = `${process.env.CLIENT_URL}/reset-password/${resetToken}`;
    await emailService.sendPasswordResetEmail(user.email, resetUrl);

    res.status(200).json({
      message: 'Password reset email sent'
    });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({ error: 'Failed to send reset email' });
  }
};

// Reset password
exports.resetPassword = async (req, res) => {
  try {
    const { token, password } = req.body;

    // Hash token
    const hashedToken = crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    // Find user with valid token
    const user = await User.findOne({
      resetPasswordToken: hashedToken,
      resetPasswordExpiry: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({ error: 'Invalid or expired token' });
    }

    // Update password
    user.password = password;
    user.resetPasswordToken = null;
    user.resetPasswordExpiry = null;
    await user.save();

    res.status(200).json({
      message: 'Password reset successful'
    });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({ error: 'Failed to reset password' });
  }
};

// Change password
exports.changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const user = await User.findById(req.user.id).select('+password');

    // Verify current password
    const isPasswordValid = await user.comparePassword(currentPassword);
    
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Current password is incorrect' });
    }

    // Update password
    user.password = newPassword;
    await user.save();

    res.status(200).json({
      message: 'Password changed successfully'
    });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({ error: 'Failed to change password' });
  }
};

// Delete account
exports.deleteAccount = async (req, res) => {
  try {
    const { password } = req.body;
    const user = await User.findById(req.user.id).select('+password');

    // Verify password
    const isPasswordValid = await user.comparePassword(password);
    
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Password is incorrect' });
    }

    // Soft delete account
    user.isActive = false;
    user.deleted = true;
    user.deletedAt = new Date();
    await user.save();

    res.status(200).json({
      message: 'Account deleted successfully'
    });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({ error: 'Failed to delete account' });
  }
};