const redisClient = require('../utils/redis');

module.exports = (io, socket) => {
  // Subscribe to notifications
  socket.on('notifications:subscribe', async (userId) => {
    try {
      // Join user's notification room
      socket.join(`notifications:${userId}`);
      
      // Store socket mapping
      await redisClient.hset('notification:sockets', userId, socket.id);
      
      socket.emit('notifications:subscribed', { success: true });
    } catch (error) {
      console.error('Notification subscribe error:', error);
      socket.emit('error', { message: 'Failed to subscribe to notifications' });
    }
  });

  // Send notification to specific user
  socket.on('notification:send', async (data) => {
    try {
      const { userId, notification } = data;
      
      // Emit to user's notification room
      io.to(`notifications:${userId}`).emit('notification:new', notification);
      
      // Store notification in database (implement as needed)
      
      socket.emit('notification:sent', { success: true });
    } catch (error) {
      console.error('Send notification error:', error);
      socket.emit('error', { message: 'Failed to send notification' });
    }
  });

  // Mark notification as read
  socket.on('notification:read', async (data) => {
    try {
      const { notificationId } = data;
      
      // Update notification status in database
      
      socket.emit('notification:marked-read', { notificationId });
    } catch (error) {
      console.error('Mark notification read error:', error);
      socket.emit('error', { message: 'Failed to mark notification as read' });
    }
  });

  // Unsubscribe from notifications
  socket.on('notifications:unsubscribe', async (userId) => {
    try {
      socket.leave(`notifications:${userId}`);
      await redisClient.hdel('notification:sockets', userId);
      
      socket.emit('notifications:unsubscribed', { success: true });
    } catch (error) {
      console.error('Notification unsubscribe error:', error);
    }
  });
};