# Super App Backend

## 🚀 Features

- **Authentication**: JWT-based authentication with phone/email login, social login (Google, Facebook, Apple)
- **Real-time Chat**: WebSocket-based chat with Socket.IO
- **Payment Processing**: Integration with Stripe and PayPal
- **File Uploads**: Support for images, videos, and documents
- **Push Notifications**: FCM integration for mobile notifications
- **Database**: MongoDB with Mongoose ODM
- **Caching**: Redis for session management and caching
- **Security**: Helmet, rate limiting, input validation, password hashing with bcrypt

## 📋 Prerequisites

- Node.js 16+ 
- MongoDB 5+
- Redis 6+
- npm or yarn

## 🛠️ Installation

1. Install dependencies:
```bash
npm install
```

2. Copy environment variables:
```bash
cp .env.example .env
```

3. Configure your `.env` file with your actual credentials

## 🏃‍♂️ Running the Server

### Development
```bash
npm run dev
```

### Production
```bash
npm start
```

### With Docker
```bash
docker-compose up
```

## 📁 Project Structure

```
backend/
├── controllers/     # Request handlers
├── models/         # MongoDB models
├── routes/         # API routes
├── middleware/     # Custom middleware
├── services/       # Business logic
├── sockets/        # Socket.IO handlers
├── utils/          # Helper functions
├── .env.example    # Environment variables template
├── server.js       # Main application file
└── package.json    # Dependencies
```

## 🔑 API Endpoints

### Authentication
- `POST /api/auth/register/phone` - Register with phone
- `POST /api/auth/verify-otp` - Verify OTP
- `POST /api/auth/login/phone` - Login with phone
- `POST /api/auth/login/email` - Login with email
- `POST /api/auth/login/social` - Social login
- `POST /api/auth/refresh` - Refresh token
- `POST /api/auth/logout` - Logout
- `POST /api/auth/forgot-password` - Password reset
- `POST /api/auth/reset-password` - Reset password
- `POST /api/auth/change-password` - Change password

### User
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update profile
- `POST /api/users/avatar` - Upload avatar
- `DELETE /api/users/account` - Delete account

### Chat
- `GET /api/chat` - Get user's chats
- `POST /api/chat` - Create new chat
- `GET /api/chat/:chatId/messages` - Get chat messages
- `POST /api/chat/:chatId/messages` - Send message
- `DELETE /api/chat/:chatId/messages/:messageId` - Delete message

### Payments
- `GET /api/payments/methods` - Get payment methods
- `POST /api/payments/methods` - Add payment method
- `POST /api/payments/charge` - Process payment
- `POST /api/payments/refund` - Process refund

### E-commerce
- `GET /api/ecommerce/products` - Get products
- `GET /api/ecommerce/products/:id` - Get product details
- `GET /api/ecommerce/cart` - Get cart
- `POST /api/ecommerce/cart` - Add to cart
- `DELETE /api/ecommerce/cart/:itemId` - Remove from cart
- `POST /api/ecommerce/orders` - Create order

### Delivery
- `GET /api/delivery/restaurants` - Get restaurants
- `GET /api/delivery/restaurants/:id/menu` - Get menu
- `POST /api/delivery/orders` - Place order
- `GET /api/delivery/orders/:id/track` - Track order

### Social
- `GET /api/social/posts` - Get posts feed
- `POST /api/social/posts` - Create post
- `POST /api/social/posts/:id/like` - Like post
- `POST /api/social/posts/:id/comment` - Comment on post

### Streaming
- `GET /api/streaming/streams` - Get live streams
- `POST /api/streaming/start` - Start streaming
- `POST /api/streaming/stop` - Stop streaming

### Files
- `POST /api/files/upload` - Upload file
- `GET /api/files/:id` - Get file
- `DELETE /api/files/:id` - Delete file

## 🔌 WebSocket Events

### Chat Events
- `chat:join` - Join chat rooms
- `message:send` - Send message
- `message:read` - Mark message as read
- `typing:start` - Start typing
- `typing:stop` - Stop typing
- `call:start` - Start call
- `call:join` - Join call
- `call:leave` - Leave call

### Notification Events
- `notifications:subscribe` - Subscribe to notifications
- `notification:send` - Send notification
- `notification:read` - Mark as read

### Stream Events
- `stream:join` - Join stream
- `stream:leave` - Leave stream
- `stream:chat` - Send chat message
- `stream:gift` - Send gift

## 🔒 Security

- JWT authentication
- Password hashing with bcrypt
- Rate limiting
- Input validation
- SQL injection prevention
- XSS protection with Helmet
- CORS configuration

## 📊 Database Schema

### User Model
- Basic info (phone, email, username)
- Profile (avatar, bio, location)
- Security (2FA, devices)
- Privacy settings
- Subscription info
- Wallet balance

### Chat Model
- Chat types (private, group, channel)
- Participants with roles
- Messages with attachments
- Read receipts
- Typing indicators
- Call information

### Payment Model
- Payment methods
- Transactions
- Subscriptions
- Wallet transactions

## 🐳 Docker Support

```yaml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "5000:5000"
    environment:
      - NODE_ENV=production
    depends_on:
      - mongodb
      - redis
  
  mongodb:
    image: mongo:5
    volumes:
      - mongo_data:/data/db
  
  redis:
    image: redis:6-alpine
    volumes:
      - redis_data:/data

volumes:
  mongo_data:
  redis_data:
```

## 📝 Environment Variables

See `.env.example` for all required environment variables.

Key variables:
- `MONGODB_URI` - MongoDB connection string
- `JWT_SECRET` - Secret key for JWT
- `STRIPE_SECRET_KEY` - Stripe API key
- `TWILIO_ACCOUNT_SID` - Twilio account
- `REDIS_URL` - Redis connection

## 🧪 Testing

```bash
npm test
```

## 📄 License

MIT