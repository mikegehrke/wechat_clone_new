const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');
const dotenv = require('dotenv');
const { createServer } = require('http');
const { Server } = require('socket.io');

// Load environment variables
dotenv.config();

// Initialize Express app
const app = express();
const httpServer = createServer(app);

// Initialize Socket.IO
const io = new Server(httpServer, {
  cors: {
    origin: '*',
    credentials: true
  }
});

// In-memory data storage for development
const memoryStore = {
  users: [],
  chats: [],
  messages: [],
  sessions: new Map(),
  otps: new Map()
};

// Middleware
app.use(helmet());
app.use(cors({
  origin: '*',
  credentials: true
}));
app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(morgan('dev'));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    message: 'Backend is running in development mode with in-memory storage'
  });
});

// Simplified Auth Routes
app.post('/api/auth/send-otp', async (req, res) => {
  const { phoneNumber } = req.body;
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  
  // Store OTP in memory
  memoryStore.otps.set(phoneNumber, {
    otp,
    expires: Date.now() + 600000 // 10 minutes
  });
  
  console.log(`📱 OTP for ${phoneNumber}: ${otp}`);
  
  res.json({
    message: 'OTP sent successfully',
    phoneNumber,
    // For development, return OTP in response
    dev_otp: otp
  });
});

app.post('/api/auth/verify-otp', async (req, res) => {
  const { phoneNumber, otp, password } = req.body;
  
  const storedOTP = memoryStore.otps.get(phoneNumber);
  
  if (!storedOTP || storedOTP.otp !== otp || storedOTP.expires < Date.now()) {
    return res.status(400).json({ error: 'Invalid or expired OTP' });
  }
  
  // Create or update user
  let user = memoryStore.users.find(u => u.phoneNumber === phoneNumber);
  
  if (!user) {
    user = {
      id: 'user_' + Date.now(),
      phoneNumber,
      username: 'user_' + phoneNumber.slice(-4),
      displayName: 'User ' + phoneNumber.slice(-4),
      password, // In production, this should be hashed
      createdAt: new Date(),
      isVerified: true
    };
    memoryStore.users.push(user);
  } else {
    user.password = password;
  }
  
  // Create session
  const token = 'token_' + Date.now() + '_' + Math.random().toString(36);
  memoryStore.sessions.set(token, user);
  
  // Clear OTP
  memoryStore.otps.delete(phoneNumber);
  
  res.json({
    message: 'Registration successful',
    user: {
      id: user.id,
      phoneNumber: user.phoneNumber,
      username: user.username,
      displayName: user.displayName
    },
    tokens: {
      accessToken: token,
      refreshToken: token + '_refresh'
    }
  });
});

app.post('/api/auth/login/phone', async (req, res) => {
  const { phoneNumber, password } = req.body;
  
  const user = memoryStore.users.find(u => 
    u.phoneNumber === phoneNumber && u.password === password
  );
  
  if (!user) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  
  const token = 'token_' + Date.now() + '_' + Math.random().toString(36);
  memoryStore.sessions.set(token, user);
  
  res.json({
    message: 'Login successful',
    user: {
      id: user.id,
      phoneNumber: user.phoneNumber,
      username: user.username,
      displayName: user.displayName
    },
    tokens: {
      accessToken: token,
      refreshToken: token + '_refresh'
    }
  });
});

app.post('/api/auth/register/phone', async (req, res) => {
  const { phoneNumber, username, displayName } = req.body;
  
  // Check if user exists
  const existing = memoryStore.users.find(u => 
    u.phoneNumber === phoneNumber || u.username === username
  );
  
  if (existing) {
    return res.status(409).json({ error: 'User already exists' });
  }
  
  // Send OTP
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  memoryStore.otps.set(phoneNumber, {
    otp,
    expires: Date.now() + 600000,
    registrationData: { phoneNumber, username, displayName }
  });
  
  console.log(`📱 Registration OTP for ${phoneNumber}: ${otp}`);
  
  res.json({
    message: 'OTP sent successfully',
    phoneNumber,
    dev_otp: otp
  });
});

// Chat endpoints
app.get('/api/chat', (req, res) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(' ')[1];
  const user = memoryStore.sessions.get(token);
  
  if (!user) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  
  const userChats = memoryStore.chats.filter(chat => 
    chat.participants.includes(user.id)
  );
  
  res.json({ chats: userChats });
});

app.post('/api/chat', (req, res) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(' ')[1];
  const user = memoryStore.sessions.get(token);
  
  if (!user) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  
  const { type = 'private', participantIds, name, description } = req.body;
  
  const chat = {
    id: 'chat_' + Date.now(),
    type,
    participants: [user.id, ...participantIds],
    name,
    description,
    messages: [],
    createdAt: new Date()
  };
  
  memoryStore.chats.push(chat);
  
  res.status(201).json({ chat });
});

// User profile
app.get('/api/users/profile', (req, res) => {
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(' ')[1];
  const user = memoryStore.sessions.get(token);
  
  if (!user) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  
  res.json({ 
    user: {
      id: user.id,
      phoneNumber: user.phoneNumber,
      username: user.username,
      displayName: user.displayName
    }
  });
});

// Placeholder routes for other features
app.get('/api/ecommerce/products', (req, res) => {
  res.json({ products: [] });
});

app.get('/api/delivery/restaurants', (req, res) => {
  res.json({ restaurants: [] });
});

app.get('/api/social/posts', (req, res) => {
  res.json({ posts: [] });
});

app.get('/api/streaming/streams', (req, res) => {
  res.json({ streams: [] });
});

app.get('/api/games/games', (req, res) => {
  res.json({ games: [] });
});

app.get('/api/professional/professionals', (req, res) => {
  res.json({ professionals: [] });
});

app.get('/api/dating/profiles', (req, res) => {
  res.json({ profiles: [] });
});

app.post('/api/files/upload', (req, res) => {
  res.json({ url: 'https://placeholder.com/uploaded-file.jpg' });
});

app.get('/api/notifications', (req, res) => {
  res.json({ notifications: [] });
});

app.get('/api/payments/methods', (req, res) => {
  res.json({ methods: [] });
});

app.post('/api/payments/charge', (req, res) => {
  res.json({ success: true, transactionId: 'txn_' + Date.now() });
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('🔌 New socket connection:', socket.id);

  socket.on('chat:join', (userId) => {
    console.log(`User ${userId} joined chat`);
    socket.join(`user:${userId}`);
    socket.emit('chat:joined', { success: true });
  });

  socket.on('notifications:subscribe', (userId) => {
    console.log(`User ${userId} subscribed to notifications`);
    socket.join(`notifications:${userId}`);
    socket.emit('notifications:subscribed', { success: true });
  });

  socket.on('message:send', (data) => {
    console.log('Message sent:', data);
    
    const message = {
      id: 'msg_' + Date.now(),
      ...data,
      timestamp: new Date()
    };
    
    // Store message in memory
    memoryStore.messages.push(message);
    
    // Broadcast to chat room
    io.to(`chat:${data.chatId}`).emit('message:new', {
      chatId: data.chatId,
      message
    });
  });

  socket.on('disconnect', () => {
    console.log('🔌 Socket disconnected:', socket.id);
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: {
      message: err.message || 'Internal server error',
      status: err.status || 500
    }
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: {
      message: 'Route not found',
      status: 404
    }
  });
});

// Start server
const PORT = process.env.PORT || 5000;
httpServer.listen(PORT, () => {
  console.log(`🚀 Development server is running on port ${PORT}`);
  console.log(`📍 Environment: development (in-memory storage)`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`\n⚠️  Note: This is a development server with in-memory storage.`);
  console.log(`    Data will be lost when the server restarts.`);
  console.log(`    For production, use the full server.js with MongoDB and Redis.`);
});

module.exports = { app, io };