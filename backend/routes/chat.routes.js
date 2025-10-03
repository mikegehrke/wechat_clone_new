const express = require('express');
const router = express.Router();
const Chat = require('../models/Chat.model');
const { authenticate } = require('../middleware/auth.middleware');

// Get user's chats
router.get('/', authenticate, async (req, res) => {
  try {
    const chats = await Chat.find({
      'participants.user': req.userId,
      deleted: false
    })
    .populate('participants.user', 'username displayName avatar')
    .populate('lastMessage.sender', 'username displayName')
    .sort('-lastActivity')
    .limit(50);
    
    res.json({ chats });
  } catch (error) {
    res.status(500).json({ error: 'Failed to get chats' });
  }
});

// Create new chat
router.post('/', authenticate, async (req, res) => {
  try {
    const { type = 'private', participantIds, name, description } = req.body;
    
    const participants = [
      { user: req.userId, role: type === 'private' ? 'member' : 'owner' }
    ];
    
    participantIds.forEach(id => {
      if (id !== req.userId) {
        participants.push({ user: id, role: 'member' });
      }
    });
    
    const chat = new Chat({
      type,
      participants,
      name,
      description
    });
    
    await chat.save();
    await chat.populate('participants.user', 'username displayName avatar');
    
    res.status(201).json({ chat });
  } catch (error) {
    res.status(500).json({ error: 'Failed to create chat' });
  }
});

// Get chat messages
router.get('/:chatId/messages', authenticate, async (req, res) => {
  try {
    const { chatId } = req.params;
    const { limit = 50, before } = req.query;
    
    const chat = await Chat.findById(chatId);
    
    if (!chat || !chat.isParticipant(req.userId)) {
      return res.status(404).json({ error: 'Chat not found' });
    }
    
    let messages = chat.messages;
    
    if (before) {
      const beforeIndex = messages.findIndex(m => m._id.toString() === before);
      if (beforeIndex > 0) {
        messages = messages.slice(Math.max(0, beforeIndex - limit), beforeIndex);
      }
    } else {
      messages = messages.slice(-limit);
    }
    
    res.json({ messages });
  } catch (error) {
    res.status(500).json({ error: 'Failed to get messages' });
  }
});

module.exports = router;