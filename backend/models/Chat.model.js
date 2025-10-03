const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  content: {
    type: String,
    required: function() {
      return !this.attachments || this.attachments.length === 0;
    }
  },
  type: {
    type: String,
    enum: ['text', 'image', 'video', 'audio', 'file', 'location', 'contact', 'sticker'],
    default: 'text'
  },
  attachments: [{
    url: String,
    publicId: String,
    type: String,
    name: String,
    size: Number,
    thumbnail: String
  }],
  location: {
    latitude: Number,
    longitude: Number,
    address: String
  },
  contact: {
    name: String,
    phone: String,
    email: String
  },
  replyTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Message'
  },
  forwarded: {
    type: Boolean,
    default: false
  },
  edited: {
    type: Boolean,
    default: false
  },
  editedAt: Date,
  delivered: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    deliveredAt: Date
  }],
  read: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    readAt: Date
  }],
  reactions: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    emoji: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  deleted: {
    type: Boolean,
    default: false
  },
  deletedFor: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }]
}, {
  timestamps: true
});

const chatSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ['private', 'group', 'channel'],
    default: 'private'
  },
  participants: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    role: {
      type: String,
      enum: ['member', 'admin', 'owner'],
      default: 'member'
    },
    joinedAt: {
      type: Date,
      default: Date.now
    },
    leftAt: Date,
    muted: {
      type: Boolean,
      default: false
    },
    mutedUntil: Date,
    lastRead: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Message'
    },
    unreadCount: {
      type: Number,
      default: 0
    }
  }],
  
  // Group/Channel specific fields
  name: {
    type: String,
    maxlength: 100
  },
  description: {
    type: String,
    maxlength: 500
  },
  avatar: {
    url: String,
    publicId: String
  },
  isPublic: {
    type: Boolean,
    default: false
  },
  inviteLink: String,
  inviteLinkExpiry: Date,
  
  // Messages
  messages: [messageSchema],
  lastMessage: messageSchema,
  lastActivity: {
    type: Date,
    default: Date.now
  },
  
  // Settings
  settings: {
    encryption: {
      type: Boolean,
      default: false
    },
    disappearingMessages: {
      enabled: {
        type: Boolean,
        default: false
      },
      duration: Number // in seconds
    },
    onlyAdminsCanSend: {
      type: Boolean,
      default: false
    },
    onlyAdminsCanEditInfo: {
      type: Boolean,
      default: true
    },
    maxMembers: {
      type: Number,
      default: 256
    }
  },
  
  // Call information
  activeCall: {
    id: String,
    type: {
      type: String,
      enum: ['voice', 'video']
    },
    startedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    startedAt: Date,
    participants: [{
      user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      joinedAt: Date,
      leftAt: Date
    }]
  },
  
  // Pinned messages
  pinnedMessages: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Message'
  }],
  
  // Metadata
  metadata: {
    type: Map,
    of: mongoose.Schema.Types.Mixed
  },
  
  // Soft delete
  deleted: {
    type: Boolean,
    default: false
  },
  deletedAt: Date
}, {
  timestamps: true
});

// Indexes
chatSchema.index({ 'participants.user': 1 });
chatSchema.index({ type: 1 });
chatSchema.index({ lastActivity: -1 });
chatSchema.index({ 'messages.sender': 1 });
chatSchema.index({ 'messages.createdAt': -1 });

// Virtual for member count
chatSchema.virtual('memberCount').get(function() {
  return this.participants.filter(p => !p.leftAt).length;
});

// Add message to chat
chatSchema.methods.addMessage = async function(messageData) {
  const message = {
    _id: new mongoose.Types.ObjectId(),
    ...messageData,
    createdAt: new Date()
  };
  
  this.messages.push(message);
  this.lastMessage = message;
  this.lastActivity = new Date();
  
  // Update unread counts for other participants
  this.participants.forEach(participant => {
    if (participant.user.toString() !== messageData.sender.toString()) {
      participant.unreadCount = (participant.unreadCount || 0) + 1;
    }
  });
  
  await this.save();
  return message;
};

// Mark messages as read
chatSchema.methods.markAsRead = async function(userId, messageId) {
  const participant = this.participants.find(
    p => p.user.toString() === userId.toString()
  );
  
  if (participant) {
    participant.lastRead = messageId;
    participant.unreadCount = 0;
    
    // Update read status in messages
    this.messages.forEach(msg => {
      if (!msg.read.find(r => r.user.toString() === userId.toString())) {
        msg.read.push({
          user: userId,
          readAt: new Date()
        });
      }
    });
    
    await this.save();
  }
};

// Add participant to group
chatSchema.methods.addParticipant = async function(userId, role = 'member') {
  const existingParticipant = this.participants.find(
    p => p.user.toString() === userId.toString()
  );
  
  if (existingParticipant) {
    if (existingParticipant.leftAt) {
      existingParticipant.leftAt = undefined;
      existingParticipant.joinedAt = new Date();
    }
  } else {
    this.participants.push({
      user: userId,
      role,
      joinedAt: new Date()
    });
  }
  
  await this.save();
};

// Remove participant from group
chatSchema.methods.removeParticipant = async function(userId) {
  const participant = this.participants.find(
    p => p.user.toString() === userId.toString()
  );
  
  if (participant) {
    participant.leftAt = new Date();
    await this.save();
  }
};

// Check if user is participant
chatSchema.methods.isParticipant = function(userId) {
  return this.participants.some(
    p => p.user.toString() === userId.toString() && !p.leftAt
  );
};

// Check if user is admin
chatSchema.methods.isAdmin = function(userId) {
  const participant = this.participants.find(
    p => p.user.toString() === userId.toString()
  );
  return participant && ['admin', 'owner'].includes(participant.role);
};

// Get unread count for user
chatSchema.methods.getUnreadCount = function(userId) {
  const participant = this.participants.find(
    p => p.user.toString() === userId.toString()
  );
  return participant ? participant.unreadCount || 0 : 0;
};

// Delete message
chatSchema.methods.deleteMessage = async function(messageId, userId, forEveryone = false) {
  const message = this.messages.id(messageId);
  
  if (!message) return null;
  
  if (forEveryone && message.sender.toString() === userId.toString()) {
    message.deleted = true;
    message.content = 'This message was deleted';
    message.attachments = [];
  } else {
    message.deletedFor.push(userId);
  }
  
  await this.save();
  return message;
};

// Edit message
chatSchema.methods.editMessage = async function(messageId, newContent, userId) {
  const message = this.messages.id(messageId);
  
  if (!message || message.sender.toString() !== userId.toString()) {
    return null;
  }
  
  message.content = newContent;
  message.edited = true;
  message.editedAt = new Date();
  
  await this.save();
  return message;
};

const Chat = mongoose.model('Chat', chatSchema);

module.exports = Chat;