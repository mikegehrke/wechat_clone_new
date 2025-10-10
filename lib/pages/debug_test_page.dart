import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../utils/simple_test_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugTestPage extends StatefulWidget {
  const DebugTestPage({super.key});

  @override
  State<DebugTestPage> createState() => _DebugTestPageState();
}

class _DebugTestPageState extends State<DebugTestPage> {
  String _status = 'Ready to test...';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug & Test'),
        backgroundColor: const Color(0xFF07C160),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current User Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👤 Current User',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('ID: ${currentUser?.id ?? "Not logged in"}'),
                    Text('Email: ${currentUser?.email ?? "N/A"}'),
                    Text('Username: ${currentUser?.username ?? "N/A"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Buttons
            const Text(
              '🧪 Test Functions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createTestData,
              icon: const Icon(Icons.science),
              label: const Text('🚀 Create Test Users & Chats'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkAllUsers,
              icon: const Icon(Icons.people),
              label: const Text('Check All Users'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF07C160),
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkMyChats,
              icon: const Icon(Icons.chat),
              label: const Text('Check My Chats'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createTestChat,
              icon: const Icon(Icons.add_comment),
              label: const Text('Create Test Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendTestMessage,
              icon: const Icon(Icons.send),
              label: const Text('Send Test Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkFirebaseConnection,
              icon: const Icon(Icons.cloud),
              label: const Text('Check Firebase Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.all(16),
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAllUsers() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking users...';
    });

    try {
      final users = await UserService.getUsers();
      setState(() {
        _status = '✅ Found ${users.length} users:\n';
        for (var user in users) {
          _status += '  - ${user.username ?? user.email} (${user.id})\n';
        }
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkMyChats() async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser == null) {
      setState(() => _status = '❌ Not logged in');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Checking chats...';
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser.id)
          .get();

      setState(() {
        _status = '✅ Found ${snapshot.docs.length} chats:\n';
        for (var doc in snapshot.docs) {
          final data = doc.data();
          _status += '  - ${doc.id}: ${data['type'] ?? "unknown"}\n';
          _status += '    Participants: ${data['participants']}\n';
        }
        if (snapshot.docs.isEmpty) {
          _status = '📭 No chats found for this user';
        }
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTestChat() async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser == null) {
      setState(() => _status = '❌ Not logged in');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Creating test chat...';
    });

    try {
      // Get all users
      final users = await UserService.getUsers();
      final otherUsers = users.where((u) => u.id != currentUser.id).toList();

      if (otherUsers.isEmpty) {
        setState(() => _status = '❌ No other users found. Create another account first!');
        setState(() => _isLoading = false);
        return;
      }

      // Create chat with first other user
      final otherUser = otherUsers.first;
      final chatId = await ChatService.getOrCreateDirectChat(
        userId1: currentUser.id,
        userId2: otherUser.id,
      );

      setState(() {
        _status = '✅ Created chat!\n';
        _status += '  Chat ID: $chatId\n';
        _status += '  With: ${otherUser.username ?? otherUser.email}\n';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createTestData() async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser == null) {
      setState(() => _status = '❌ You must be logged in!');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Creating simple test chats...\n';
    });

    try {
      final result = await SimpleTestData.createQuickTestChats(currentUser.id);
      if (mounted) {
        setState(() {
          _status = result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = '❌ Error: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendTestMessage() async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (currentUser == null) {
      setState(() => _status = '❌ Not logged in');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Sending test message...';
    });

    try {
      // Get first chat
      final snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUser.id)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() => _status = '❌ No chats found. Create a chat first!');
        setState(() => _isLoading = false);
        return;
      }

      final chatId = snapshot.docs.first.id;
      
      // Send message
      await ChatService.sendMessage(
        chatId: chatId,
        senderId: currentUser.id,
        content: 'Test message from Debug page! 🎉',
      );

      setState(() {
        _status = '✅ Message sent!\n';
        _status += '  Chat ID: $chatId\n';
        _status += '  Content: Test message from Debug page! 🎉\n';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkFirebaseConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking Firebase...';
    });

    try {
      // Try to read from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .limit(1)
          .get();

      setState(() {
        _status = '✅ Firebase connected!\n';
        _status += '  Project: wechat-super-app-2024\n';
        _status += '  Users collection accessible: ${snapshot.docs.isNotEmpty}\n';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Firebase Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
