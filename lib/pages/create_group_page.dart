import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../models/app_foundations.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedMembers = [];
  File? _groupImage;
  final ImagePicker _picker = ImagePicker();
  bool _isCreating = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Group',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          if (_selectedMembers.isNotEmpty)
            TextButton(
              onPressed: _isCreating ? null : () => _showGroupSetup(currentUserId),
              child: Text(
                'Next',
                style: TextStyle(
                  color: _isCreating ? Colors.grey : const Color(0xFF07C160),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Selected members chip list
          if (_selectedMembers.isNotEmpty)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedMembers.length,
                itemBuilder: (context, index) {
                  final memberId = _selectedMembers[index];
                  return FutureBuilder<UserAccount?>(
                    future: UserService.getUserById(memberId),
                    builder: (context, snapshot) {
                      final user = snapshot.data;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: user?.avatarUrl != null
                                      ? NetworkImage(user!.avatarUrl!)
                                      : null,
                                  backgroundColor: Colors.grey[300],
                                  child: user?.avatarUrl == null
                                      ? Text(
                                          (user?.username ?? 'U')[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedMembers.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 60,
                              child: Text(
                                user?.username ?? 'Unknown',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          
          const Divider(height: 1),
          
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          
          // Contacts list
          Expanded(
            child: FutureBuilder<List<UserAccount>>(
              future: UserService.getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var users = snapshot.data ?? [];
                
                // Filter out current user
                users = users.where((u) => u.id != currentUserId).toList();
                
                // Filter by search
                if (_searchController.text.isNotEmpty) {
                  users = users.where((u) {
                    return (u.username ?? '').toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    );
                  }).toList();
                }

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No contacts found',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = _selectedMembers.contains(user.id);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: user.avatarUrl == null
                            ? Text(
                                (user.username ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      title: Text(user.username ?? 'Unknown'),
                      subtitle: user.bio != null ? Text(user.bio!) : null,
                      trailing: Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedMembers.add(user.id);
                            } else {
                              _selectedMembers.remove(user.id);
                            }
                          });
                        },
                        activeColor: const Color(0xFF07C160),
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedMembers.remove(user.id);
                          } else {
                            _selectedMembers.add(user.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showGroupSetup(String currentUserId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  const Text(
                    'New Group',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _isCreating
                        ? null
                        : () => _createGroup(context, currentUserId),
                    child: Text(
                      'Create',
                      style: TextStyle(
                        color: _isCreating ? Colors.grey : const Color(0xFF07C160),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Group setup
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Group image
                    GestureDetector(
                      onTap: _pickGroupImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _groupImage != null
                                ? FileImage(_groupImage!)
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: _groupImage == null
                                ? const Icon(
                                    Icons.group,
                                    size: 48,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF07C160),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Group name input
                    TextField(
                      controller: _groupNameController,
                      decoration: InputDecoration(
                        labelText: 'Group Name',
                        hintText: 'Enter group name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF07C160), width: 2),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Selected members
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Members: ${_selectedMembers.length}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Members list
                    ...(_selectedMembers.map((memberId) {
                      return FutureBuilder<UserAccount?>(
                        future: UserService.getUserById(memberId),
                        builder: (context, snapshot) {
                          final user = snapshot.data;
                          if (user == null) return const SizedBox();
                          
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              backgroundColor: Colors.grey[300],
                              child: user.avatarUrl == null
                                  ? Text(
                                      (user.username ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(user.username ?? 'Unknown'),
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      );
                    })),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickGroupImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _groupImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _createGroup(BuildContext context, String currentUserId) async {
    final groupName = _groupNameController.text.trim();
    
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      String? groupAvatarUrl;
      
      // Upload group image if selected
      if (_groupImage != null) {
        groupAvatarUrl = await ChatService.uploadFile(
          chatId: 'group_avatars',
          userId: currentUserId,
          file: _groupImage!,
          fileName: 'group_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      // Create group
      final participants = [..._selectedMembers, currentUserId];
      await ChatService.createGroupChat(
        groupName: groupName,
        participants: participants,
        creatorId: currentUserId,
        groupAvatar: groupAvatarUrl,
      );

      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        Navigator.pop(context); // Go back to chat list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group "$groupName" created!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $e')),
        );
      }
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }
}
