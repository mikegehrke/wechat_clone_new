const Chat = require('../models/Chat.model');
const User = require('../models/User.model');
const redisClient = require('../utils/redis');

module.exports = (io, socket) => {
  // Join user to their rooms
  socket.on('chat:join', async (userId) => {
    try {
      // Store user socket mapping
      await redisClient.hset('user:sockets', userId, socket.id);
      await redisClient.hset('socket:users', socket.id, userId);
      
      // Set user online status
      await redisClient.sadd('users:online', userId);
      
      // Join user to their chat rooms
      const userChats = await Chat.find({
        'participants.user': userId,
        deleted: false
      }).select('_id');
      
      userChats.forEach(chat => {
        socket.join(`chat:${chat._id}`);
      });
      
      // Notify friends that user is online
      const user = await User.findById(userId).select('friends');
      if (user && user.friends) {
        for (const friendId of user.friends) {
          const friendSocketId = await redisClient.hget('user:sockets', friendId.toString());
          if (friendSocketId) {
            io.to(friendSocketId).emit('friend:online', {
              userId,
              status: 'online'
            });
          }
        }
      }
      
      socket.emit('chat:joined', { success: true });
    } catch (error) {
      console.error('Chat join error:', error);
      socket.emit('error', { message: 'Failed to join chat' });
    }
  });

  // Send message
  socket.on('message:send', async (data) => {
    try {
      const { chatId, content, type = 'text', attachments, replyTo } = data;
      const userId = await redisClient.hget('socket:users', socket.id);
      
      if (!userId) {
        return socket.emit('error', { message: 'User not authenticated' });
      }
      
      // Find chat and verify user is participant
      const chat = await Chat.findById(chatId);
      
      if (!chat || !chat.isParticipant(userId)) {
        return socket.emit('error', { message: 'Chat not found or access denied' });
      }
      
      // Add message to chat
      const message = await chat.addMessage({
        sender: userId,
        content,
        type,
        attachments,
        replyTo
      });
      
      // Populate sender info
      const populatedMessage = await Chat.populate(message, {
        path: 'sender',
        select: 'username displayName avatar'
      });
      
      // Emit to all participants in the room
      io.to(`chat:${chatId}`).emit('message:new', {
        chatId,
        message: populatedMessage
      });
      
      // Send push notifications to offline users
      for (const participant of chat.participants) {
        if (participant.user.toString() !== userId) {
          const isOnline = await redisClient.sismember('users:online', participant.user.toString());
          
          if (!isOnline) {
            // Queue push notification
            await redisClient.rpush('notifications:queue', JSON.stringify({
              type: 'message',
              userId: participant.user.toString(),
              data: {
                chatId,
                message: populatedMessage
              }
            }));
          }
        }
      }
    } catch (error) {
      console.error('Send message error:', error);
      socket.emit('error', { message: 'Failed to send message' });
    }
  });

  // Mark messages as read
  socket.on('message:read', async (data) => {
    try {
      const { chatId, messageId } = data;
      const userId = await redisClient.hget('socket:users', socket.id);
      
      if (!userId) {
        return socket.emit('error', { message: 'User not authenticated' });
      }
      
      const chat = await Chat.findById(chatId);
      
      if (!chat || !chat.isParticipant(userId)) {
        return socket.emit('error', { message: 'Chat not found or access denied' });
      }
      
      await chat.markAsRead(userId, messageId);
      
      // Notify sender that message was read
      const message = chat.messages.id(messageId);
      if (message) {
        const senderSocketId = await redisClient.hget('user:sockets', message.sender.toString());
        if (senderSocketId) {
          io.to(senderSocketId).emit('message:read', {
            chatId,
            messageId,
            userId
          });
        }
      }
    } catch (error) {
      console.error('Mark read error:', error);
      socket.emit('error', { message: 'Failed to mark as read' });
    }
  });

  // Typing indicator
  socket.on('typing:start', async (data) => {
    try {
      const { chatId } = data;
      const userId = await redisClient.hget('socket:users', socket.id);
      
      if (!userId) return;
      
      // Broadcast to other users in the chat
      socket.to(`chat:${chatId}`).emit('typing:start', {
        chatId,
        userId
      });
      
      // Auto-stop typing after 5 seconds
      setTimeout(async () => {
        socket.to(`chat:${chatId}`).emit('typing:stop', {
          chatId,
          userId
        });
      }, 5000);
    } catch (error) {
      console.error('Typing indicator error:', error);
    }
  });

  socket.on('typing:stop', async (data) => {
    try {
      const { chatId } = data;
      const userId = await redisClient.hget('socket:users', socket.id);
      
      if (!userId) return;
      
      socket.to(`chat:${chatId}`).emit('typing:stop', {
        chatId,
        userId
      });
    } catch (error) {
      console.error('Typing indicator error:', error);
    }
  });

  // Delete message
  socket.on('message:delete', async (data) => {
    try {
      const { chatId, messageId, forEveryone = false } = data;
      const userId = await redisClient.hget('socket:users', socket.id);
      
      if (!userId) {
        return socket.emit('error', { message: 'User not authenticated' });
      }
      
      const chat = await Chat.findById(chatId);
      
      if (!chat || !chat.isParticipant(userId)) {
        return socket.emit('error', { message: 'Chat not found or access denied' });
      }
      
      const message = await chat.deleteMessage(messageId, userId, forEveryone);
      
      if (message) {
        if (forEveryone) {
          io.to(`chat:${chatId}`).emit('message:deleted', {
            chatId,
            messageId
          });
        } else {
          socket.emit('message:deleted', {
            chatId,
            messageId
          });
        }
      }
    } catch (error) {
      console.error('Delete message error:', error);
      socket.emit('error', { message: 'Failed to delete message' });
    }
  });

  // Edit message
  socket.on('message:edit', async (data) => {
    try {
      const { chatId, messageId, newContent } = data;
      const userId = await redisClient.hget('socket:users', socket.id);
      
      if (!userId) {
        return socket.emit('error', { message: 'User not authenticated' });
      }
      
      const chat = await Chat.findById(chatId);
      
      if (!chat || !chat.isParticipant(userId)) {
        return socket.emit('error', { message: 'Chat not found or access denied' });
      }
      
      const message = await chat.editMessage(messageId, newContent, userId);
      
      if (message) {
        io.to(`chat:${chatId}`).emit('message:edited', {
          chatId,
          messageId,
          newContent,
          editedAt: message.editedAt
        });
      }
    } catch (error) {
      console.error('Edit message error:', error);
      socket.emit('error', { message: 'Failed to edit message' });
    }
  });

  // React to message
  socket.on('message:react', async (data) => {
    try {
      const { chatId, messageId, emoji } = data;
      const userId = await redisClient.hget('socket:users', socket.id);
      
      if (!userId) {
        return socket.emit('error', { message: 'User not authenticated' });
      }
      
      const chat = await Chat.findById(chatId);
      
      if (!chat || !chat.isParticipant(userId)) {
        return socket.emit('error', { message: 'Chat not found or access denied' });
      }
      
      const message = chat.messages.id(messageId);
      
      if (message) {
        // Remove existing reaction from user
        message.reactions = message.reactions.filter(
          r => r.user.toString() !== userId
        );
        
        // Add new reaction if emoji provided
        if (emoji) {
          message.reactions.push({
            user: userId,
            emoji
          });
        }
        
        await chat.save();
        
        io.to(`chat:${chatId}`).emit('message:reaction', {
          chatId,
          messageId,
          userId,
          emoji
        });
      }
    } catch (error) {
      console.error('React to message error:', error);
      socket.emit('error', { message: 'Failed to react to message' });
    }
  });

  // Voice/Video call
  socket.on('call:start', async (data) => {
    try {
      const { chatId, type } = data;
      const userId = await redisClient.hget('socket:users', socket.id);
      
      if (!userId) {
        return socket.emit('error', { message: 'User not authenticated' });
      }
      
      const chat = await Chat.findById(chatId).populate('participants.user', 'username displayName avatar');
      
      if (!chat || !chat.isParticipant(userId)) {
        return socket.emit('error', { message: 'Chat not found or access denied' });
      }
      
      // Create call session
      const callId = `call_${Date.now()}`;
      
      chat.activeCall = {
        id: callId,
        type,
        startedBy: userId,
        startedAt: new Date(),
        participants: [{
          user: userId,
          joinedAt: new Date()
        }]
      };
      
      await chat.save();
      
      // Notify other participants
      socket.to(`chat:${chatId}`).emit('call:incoming', {
        chatId,
        callId,
        type,
        caller: await User.findById(userId).select('username displayName avatar')
      });
      
      socket.emit('call:started', { chatId, callId });
    } catch (error) {
      console.error('Start call error:', error);
      socket.emit('error', { message: 'Failed to start call' });
    }
  });

  socket.on('call:join', async (data) => {
    try {
      const { chatId, callId } = data;
      const userId = await redisClient.hget('socket:users', socket.id);
      
      if (!userId) {
        return socket.emit('error', { message: 'User not authenticated' });
      }
      
      const chat = await Chat.findById(chatId);
      
      if (!chat || !chat.isParticipant(userId) || !chat.activeCall || chat.activeCall.id !== callId) {
        return socket.emit('error', { message: 'Call not found or access denied' });
      }
      
      // Add user to call participants
      const existingParticipant = chat.activeCall.participants.find(
        p => p.user.toString() === userId
      );
      
      if (!existingParticipant) {
        chat.activeCall.participants.push({
          user: userId,
          joinedAt: new Date()
        });
        await chat.save();
      }
      
      // Notify others
      socket.to(`chat:${chatId}`).emit('call:user-joined', {
        chatId,
        callId,
        userId
      });
      
      socket.emit('call:joined', { chatId, callId });
    } catch (error) {
      console.error('Join call error:', error);
      socket.emit('error', { message: 'Failed to join call' });
    }
  });

  socket.on('call:leave', async (data) => {
    try {
      const { chatId, callId } = data;
      const userId = await redisClient.hget('socket:users', socket.id);
      
      if (!userId) return;
      
      const chat = await Chat.findById(chatId);
      
      if (chat && chat.activeCall && chat.activeCall.id === callId) {
        const participant = chat.activeCall.participants.find(
          p => p.user.toString() === userId
        );
        
        if (participant) {
          participant.leftAt = new Date();
        }
        
        // Check if all participants left
        const activeParticipants = chat.activeCall.participants.filter(p => !p.leftAt);
        
        if (activeParticipants.length === 0) {
          chat.activeCall = null;
        }
        
        await chat.save();
        
        // Notify others
        socket.to(`chat:${chatId}`).emit('call:user-left', {
          chatId,
          callId,
          userId
        });
      }
    } catch (error) {
      console.error('Leave call error:', error);
    }
  });

  // WebRTC signaling
  socket.on('webrtc:offer', async (data) => {
    const { chatId, targetUserId, offer } = data;
    const userId = await redisClient.hget('socket:users', socket.id);
    
    if (!userId) return;
    
    const targetSocketId = await redisClient.hget('user:sockets', targetUserId);
    if (targetSocketId) {
      io.to(targetSocketId).emit('webrtc:offer', {
        chatId,
        userId,
        offer
      });
    }
  });

  socket.on('webrtc:answer', async (data) => {
    const { chatId, targetUserId, answer } = data;
    const userId = await redisClient.hget('socket:users', socket.id);
    
    if (!userId) return;
    
    const targetSocketId = await redisClient.hget('user:sockets', targetUserId);
    if (targetSocketId) {
      io.to(targetSocketId).emit('webrtc:answer', {
        chatId,
        userId,
        answer
      });
    }
  });

  socket.on('webrtc:ice-candidate', async (data) => {
    const { chatId, targetUserId, candidate } = data;
    const userId = await redisClient.hget('socket:users', socket.id);
    
    if (!userId) return;
    
    const targetSocketId = await redisClient.hget('user:sockets', targetUserId);
    if (targetSocketId) {
      io.to(targetSocketId).emit('webrtc:ice-candidate', {
        chatId,
        userId,
        candidate
      });
    }
  });

  // Clean up on disconnect
  socket.on('disconnect', async () => {
    try {
      const userId = await redisClient.hget('socket:users', socket.id);
      
      if (userId) {
        // Remove socket mappings
        await redisClient.hdel('user:sockets', userId);
        await redisClient.hdel('socket:users', socket.id);
        
        // Set user offline
        await redisClient.srem('users:online', userId);
        
        // Notify friends that user is offline
        const user = await User.findById(userId).select('friends');
        if (user && user.friends) {
          for (const friendId of user.friends) {
            const friendSocketId = await redisClient.hget('user:sockets', friendId.toString());
            if (friendSocketId) {
              io.to(friendSocketId).emit('friend:offline', {
                userId,
                status: 'offline'
              });
            }
          }
        }
        
        // Leave any active calls
        const userChats = await Chat.find({
          'participants.user': userId,
          'activeCall.participants.user': userId,
          deleted: false
        });
        
        for (const chat of userChats) {
          if (chat.activeCall) {
            const participant = chat.activeCall.participants.find(
              p => p.user.toString() === userId
            );
            
            if (participant && !participant.leftAt) {
              participant.leftAt = new Date();
              
              const activeParticipants = chat.activeCall.participants.filter(p => !p.leftAt);
              if (activeParticipants.length === 0) {
                chat.activeCall = null;
              }
              
              await chat.save();
              
              socket.to(`chat:${chat._id}`).emit('call:user-left', {
                chatId: chat._id,
                callId: chat.activeCall?.id,
                userId
              });
            }
          }
        }
      }
    } catch (error) {
      console.error('Disconnect cleanup error:', error);
    }
  });
};