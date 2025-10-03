const redisClient = require('../utils/redis');

module.exports = (io, socket) => {
  // Join stream room
  socket.on('stream:join', async (data) => {
    try {
      const { streamId, userId } = data;
      
      // Join stream room
      socket.join(`stream:${streamId}`);
      
      // Add viewer to Redis set
      await redisClient.sadd(`stream:${streamId}:viewers`, userId);
      
      // Get current viewer count
      const viewerCount = await redisClient.scard(`stream:${streamId}:viewers`);
      
      // Notify all viewers of new viewer
      io.to(`stream:${streamId}`).emit('stream:viewer-joined', {
        streamId,
        userId,
        viewerCount
      });
      
      socket.emit('stream:joined', { streamId, viewerCount });
    } catch (error) {
      console.error('Stream join error:', error);
      socket.emit('error', { message: 'Failed to join stream' });
    }
  });

  // Leave stream room
  socket.on('stream:leave', async (data) => {
    try {
      const { streamId, userId } = data;
      
      // Leave stream room
      socket.leave(`stream:${streamId}`);
      
      // Remove viewer from Redis set
      await redisClient.srem(`stream:${streamId}:viewers`, userId);
      
      // Get updated viewer count
      const viewerCount = await redisClient.scard(`stream:${streamId}:viewers`);
      
      // Notify all viewers
      io.to(`stream:${streamId}`).emit('stream:viewer-left', {
        streamId,
        userId,
        viewerCount
      });
      
      socket.emit('stream:left', { streamId });
    } catch (error) {
      console.error('Stream leave error:', error);
    }
  });

  // Send stream chat message
  socket.on('stream:chat', async (data) => {
    try {
      const { streamId, userId, message } = data;
      
      // Broadcast to all viewers
      io.to(`stream:${streamId}`).emit('stream:chat-message', {
        streamId,
        userId,
        message,
        timestamp: new Date()
      });
    } catch (error) {
      console.error('Stream chat error:', error);
      socket.emit('error', { message: 'Failed to send chat message' });
    }
  });

  // Send gift/donation
  socket.on('stream:gift', async (data) => {
    try {
      const { streamId, userId, gift } = data;
      
      // Broadcast gift to all viewers
      io.to(`stream:${streamId}`).emit('stream:gift-received', {
        streamId,
        userId,
        gift,
        timestamp: new Date()
      });
    } catch (error) {
      console.error('Stream gift error:', error);
      socket.emit('error', { message: 'Failed to send gift' });
    }
  });

  // Stream quality change
  socket.on('stream:quality-change', async (data) => {
    try {
      const { streamId, quality } = data;
      
      socket.emit('stream:quality-changed', {
        streamId,
        quality
      });
    } catch (error) {
      console.error('Stream quality change error:', error);
    }
  });

  // Start broadcasting
  socket.on('stream:start-broadcast', async (data) => {
    try {
      const { streamId, userId, title, description } = data;
      
      // Store stream info in Redis
      await redisClient.hset(`stream:${streamId}`, {
        broadcaster: userId,
        title,
        description,
        startedAt: new Date().toISOString(),
        status: 'live'
      });
      
      socket.emit('stream:broadcast-started', { streamId });
    } catch (error) {
      console.error('Start broadcast error:', error);
      socket.emit('error', { message: 'Failed to start broadcast' });
    }
  });

  // Stop broadcasting
  socket.on('stream:stop-broadcast', async (data) => {
    try {
      const { streamId } = data;
      
      // Update stream status
      await redisClient.hset(`stream:${streamId}`, 'status', 'ended');
      
      // Notify all viewers
      io.to(`stream:${streamId}`).emit('stream:broadcast-ended', { streamId });
      
      // Clean up viewers
      await redisClient.del(`stream:${streamId}:viewers`);
      
      socket.emit('stream:broadcast-stopped', { streamId });
    } catch (error) {
      console.error('Stop broadcast error:', error);
      socket.emit('error', { message: 'Failed to stop broadcast' });
    }
  });
};