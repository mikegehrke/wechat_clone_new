const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const userSchema = new mongoose.Schema({
  // Basic Information
  phoneNumber: {
    type: String,
    unique: true,
    sparse: true
  },
  email: {
    type: String,
    unique: true,
    sparse: true,
    lowercase: true,
    trim: true
  },
  username: {
    type: String,
    unique: true,
    required: true,
    trim: true,
    minlength: 3,
    maxlength: 30
  },
  displayName: {
    type: String,
    required: true,
    maxlength: 100
  },
  password: {
    type: String,
    select: false
  },
  
  // Profile
  avatar: {
    url: String,
    publicId: String
  },
  bio: {
    type: String,
    maxlength: 500
  },
  dateOfBirth: Date,
  gender: {
    type: String,
    enum: ['male', 'female', 'other', 'prefer_not_to_say']
  },
  
  // Verification & Status
  isVerified: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  isBanned: {
    type: Boolean,
    default: false
  },
  verificationToken: String,
  verificationExpiry: Date,
  
  // Authentication
  refreshToken: String,
  resetPasswordToken: String,
  resetPasswordExpiry: Date,
  lastLogin: Date,
  loginAttempts: {
    type: Number,
    default: 0
  },
  lockUntil: Date,
  
  // Security
  twoFactorEnabled: {
    type: Boolean,
    default: false
  },
  twoFactorSecret: String,
  devices: [{
    id: String,
    name: String,
    type: String,
    platform: String,
    lastSeen: Date,
    pushToken: String
  }],
  
  // Social Logins
  socialLogins: [{
    provider: {
      type: String,
      enum: ['google', 'facebook', 'apple', 'twitter']
    },
    providerId: String,
    email: String,
    avatar: String
  }],
  
  // Privacy Settings
  privacy: {
    profileVisibility: {
      type: String,
      enum: ['public', 'friends', 'private'],
      default: 'public'
    },
    showOnlineStatus: {
      type: Boolean,
      default: true
    },
    showLastSeen: {
      type: Boolean,
      default: true
    },
    allowMessages: {
      type: String,
      enum: ['everyone', 'friends', 'none'],
      default: 'everyone'
    },
    allowCalls: {
      type: String,
      enum: ['everyone', 'friends', 'none'],
      default: 'friends'
    }
  },
  
  // Notification Settings
  notifications: {
    push: {
      type: Boolean,
      default: true
    },
    email: {
      type: Boolean,
      default: true
    },
    sms: {
      type: Boolean,
      default: false
    },
    marketing: {
      type: Boolean,
      default: false
    }
  },
  
  // Relationships
  friends: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  blocked: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  followers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  following: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  
  // Wallet
  wallet: {
    balance: {
      type: Number,
      default: 0
    },
    currency: {
      type: String,
      default: 'USD'
    },
    pendingBalance: {
      type: Number,
      default: 0
    }
  },
  
  // Subscription
  subscription: {
    plan: {
      type: String,
      enum: ['free', 'basic', 'pro', 'premium'],
      default: 'free'
    },
    startDate: Date,
    endDate: Date,
    isActive: Boolean,
    autoRenew: {
      type: Boolean,
      default: true
    }
  },
  
  // Stats
  stats: {
    postsCount: {
      type: Number,
      default: 0
    },
    friendsCount: {
      type: Number,
      default: 0
    },
    followersCount: {
      type: Number,
      default: 0
    },
    followingCount: {
      type: Number,
      default: 0
    },
    rating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5
    },
    totalEarned: {
      type: Number,
      default: 0
    },
    totalSpent: {
      type: Number,
      default: 0
    }
  },
  
  // Location
  location: {
    type: {
      type: String,
      default: 'Point'
    },
    coordinates: [Number], // [longitude, latitude]
    address: String,
    city: String,
    state: String,
    country: String,
    zipCode: String
  },
  
  // Preferences
  preferences: {
    language: {
      type: String,
      default: 'en'
    },
    currency: {
      type: String,
      default: 'USD'
    },
    timezone: {
      type: String,
      default: 'UTC'
    },
    theme: {
      type: String,
      enum: ['light', 'dark', 'auto'],
      default: 'light'
    }
  },
  
  // Metadata
  metadata: {
    type: Map,
    of: mongoose.Schema.Types.Mixed
  }
}, {
  timestamps: true
});

// Indexes
userSchema.index({ location: '2dsphere' });
userSchema.index({ email: 1 });
userSchema.index({ phoneNumber: 1 });
userSchema.index({ username: 1 });
userSchema.index({ 'socialLogins.provider': 1, 'socialLogins.providerId': 1 });

// Virtual for full name
userSchema.virtual('fullName').get(function() {
  return this.displayName;
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    next(error);
  }
});

// Compare password
userSchema.methods.comparePassword = async function(candidatePassword) {
  if (!this.password) return false;
  return await bcrypt.compare(candidatePassword, this.password);
};

// Generate JWT token
userSchema.methods.generateAuthToken = function() {
  const token = jwt.sign(
    {
      id: this._id,
      username: this.username,
      email: this.email
    },
    process.env.JWT_SECRET,
    {
      expiresIn: process.env.JWT_EXPIRE || '7d'
    }
  );
  return token;
};

// Generate refresh token
userSchema.methods.generateRefreshToken = function() {
  const token = jwt.sign(
    { id: this._id },
    process.env.REFRESH_TOKEN_SECRET,
    {
      expiresIn: process.env.REFRESH_TOKEN_EXPIRE || '30d'
    }
  );
  return token;
};

// Check if user is locked
userSchema.methods.isLocked = function() {
  return !!(this.lockUntil && this.lockUntil > Date.now());
};

// Increment login attempts
userSchema.methods.incLoginAttempts = async function() {
  // Reset attempts if lock has expired
  if (this.lockUntil && this.lockUntil < Date.now()) {
    return this.updateOne({
      $set: { loginAttempts: 1 },
      $unset: { lockUntil: 1 }
    });
  }
  
  const updates = { $inc: { loginAttempts: 1 } };
  const maxAttempts = 5;
  const lockTime = 2 * 60 * 60 * 1000; // 2 hours
  
  if (this.loginAttempts + 1 >= maxAttempts && !this.isLocked()) {
    updates.$set = { lockUntil: Date.now() + lockTime };
  }
  
  return this.updateOne(updates);
};

// Reset login attempts
userSchema.methods.resetLoginAttempts = async function() {
  return this.updateOne({
    $set: { loginAttempts: 0 },
    $unset: { lockUntil: 1 }
  });
};

// Check if user can perform action
userSchema.methods.canPerformAction = function(action) {
  if (this.isBanned) return false;
  if (!this.isActive) return false;
  
  // Check subscription limits
  const limits = {
    free: {
      posts: 10,
      messages: 50,
      storage: 1024 * 1024 * 100 // 100MB
    },
    basic: {
      posts: 50,
      messages: 500,
      storage: 1024 * 1024 * 1024 // 1GB
    },
    pro: {
      posts: 500,
      messages: 5000,
      storage: 1024 * 1024 * 1024 * 10 // 10GB
    },
    premium: {
      posts: -1, // unlimited
      messages: -1,
      storage: -1
    }
  };
  
  const userLimits = limits[this.subscription.plan] || limits.free;
  
  // Return true for unlimited or check specific limits
  return true; // Simplified for now
};

// Remove sensitive data when converting to JSON
userSchema.methods.toJSON = function() {
  const obj = this.toObject();
  delete obj.password;
  delete obj.refreshToken;
  delete obj.resetPasswordToken;
  delete obj.verificationToken;
  delete obj.twoFactorSecret;
  delete obj.__v;
  return obj;
};

const User = mongoose.model('User', userSchema);

module.exports = User;