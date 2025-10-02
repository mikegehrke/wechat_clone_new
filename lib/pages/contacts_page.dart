import 'package:flutter/material.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search contacts...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              )
            : const Text(
                'Contacts',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'add_friend':
                  _showAddFriendDialog();
                  break;
                case 'scan_qr':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR scanner feature coming soon!'),
                    ),
                  );
                  break;
                case 'phone_contacts':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone contacts feature coming soon!'),
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_friend',
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Color(0xFF07C160)),
                    SizedBox(width: 12),
                    Text('Add Friend'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'scan_qr',
                child: Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: Color(0xFF07C160)),
                    SizedBox(width: 12),
                    Text('Scan QR Code'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'phone_contacts',
                child: Row(
                  children: [
                    Icon(Icons.contacts, color: Color(0xFF07C160)),
                    SizedBox(width: 12),
                    Text('Phone Contacts'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 7, // Header items + contacts
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeaderItem(
              icon: Icons.new_releases,
              title: 'New Friends',
              subtitle: 'Friend requests and recommendations',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New friends feature coming soon!'),
                  ),
                );
              },
            );
          } else if (index == 1) {
            return _buildHeaderItem(
              icon: Icons.group,
              title: 'Group Chats',
              subtitle: 'Manage your group conversations',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Group chats feature coming soon!'),
                  ),
                );
              },
            );
          } else {
            // Mock contact data
            final contacts = [
              {'name': 'Alice Johnson', 'status': 'Online', 'isOnline': true},
              {'name': 'Bob Smith', 'status': 'Last seen 2 hours ago', 'isOnline': false},
              {'name': 'Carol Davis', 'status': 'Online', 'isOnline': true},
              {'name': 'David Wilson', 'status': 'Last seen yesterday', 'isOnline': false},
              {'name': 'Eva Brown', 'status': 'Online', 'isOnline': true},
            ];
            
            final contact = contacts[index - 2];
            return _buildContactItem(
              name: contact['name'] as String,
              status: contact['status'] as String,
              isOnline: contact['isOnline'] as bool,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening chat with ${contact['name']}'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildHeaderItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF07C160).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF07C160),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildContactItem({
    required String name,
    required String status,
    required bool isOnline,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFF07C160),
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        status,
        style: TextStyle(
          fontSize: 14,
          color: isOnline ? const Color(0xFF07C160) : Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your friend\'s username or email'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Username or Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Friend request sent!'),
                ),
              );
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}