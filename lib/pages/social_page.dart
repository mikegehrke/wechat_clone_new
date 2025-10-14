import 'package:flutter/material.dart';
import '../models/social.dart';
import '../services/social_service.dart';
import '../widgets/social_post_card.dart';
import '../widgets/social_user_card.dart';
import '../widgets/social_chat_card.dart';
import '../widgets/social_event_card.dart';
import 'social/social_post_detail_page.dart';
import 'social/social_user_profile_page.dart';
import 'social/social_chat_page.dart';
import 'social/social_event_detail_page.dart';
import 'social/create_post_page.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<SocialPost> _feed = [];
  List<SocialUser> _users = [];
  List<SocialChat> _chats = [];
  List<SocialEvent> _events = [];
  bool _isLoading = false;
  String? _error;
  final String _currentUserId = 'demo_user_1'; // In real app, get from auth

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final futures = await Future.wait([
        SocialService.getFeed(_currentUserId),
        SocialService.searchUsers(''),
        SocialService.getUserChats(_currentUserId),
        SocialService.getEvents(),
      ]);

      setState(() {
        _feed = futures[0] as List<SocialPost>;
        _users = futures[1] as List<SocialUser>;
        _chats = futures[2] as List<SocialChat>;
        _events = futures[3] as List<SocialEvent>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Social',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              _showNotifications();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: 'Feed'),
            Tab(text: 'People'),
            Tab(text: 'Messages'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(),
          _buildPeopleTab(),
          _buildMessagesTab(),
          _buildEventsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createPost,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFeedTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_feed.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feed, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No posts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start by creating your first post!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _feed.length,
        itemBuilder: (context, index) {
          final post = _feed[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SocialPostCard(
              post: post,
              onTap: () => _navigateToPost(post),
              onLike: () => _likePost(post),
              onComment: () => _commentOnPost(post),
              onShare: () => _sharePost(post),
              onBookmark: () => _bookmarkPost(post),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeopleTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No people found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SocialUserCard(
            user: user,
            onTap: () => _navigateToUserProfile(user),
            onFollow: () => _followUser(user),
            onMessage: () => _messageUser(user),
          ),
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_chats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start a conversation with someone!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SocialChatCard(chat: chat, onTap: () => _navigateToChat(chat)),
        );
      },
    );
  }

  Widget _buildEventsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No events found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SocialEventCard(
            event: event,
            onTap: () => _navigateToEvent(event),
            onAttend: () => _attendEvent(event),
            onInterested: () => _interestedInEvent(event),
          ),
        );
      },
    );
  }

  void _createPost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostPage()),
    );
  }

  void _navigateToPost(SocialPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SocialPostDetailPage(post: post)),
    );
  }

  void _navigateToUserProfile(SocialUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SocialUserProfilePage(user: user),
      ),
    );
  }

  void _navigateToChat(SocialChat chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SocialChatPage(chat: chat)),
    );
  }

  void _navigateToEvent(SocialEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SocialEventDetailPage(event: event),
      ),
    );
  }

  void _likePost(SocialPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${post.isLiked ? 'Unliked' : 'Liked'} post')),
    );
  }

  void _commentOnPost(SocialPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment feature coming soon!')),
    );
  }

  void _sharePost(SocialPost post) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post shared!')));
  }

  void _bookmarkPost(SocialPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${post.isBookmarked ? 'Removed from' : 'Added to'} bookmarks',
        ),
      ),
    );
  }

  void _followUser(SocialUser user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${user.isPrivate ? 'Follow request sent to' : 'Started following'} ${user.displayName}',
        ),
      ),
    );
  }

  void _messageUser(SocialUser user) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Messaging ${user.displayName}')));
  }

  void _attendEvent(SocialEvent event) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Attending ${event.title}')));
  }

  void _interestedInEvent(SocialEvent event) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Marked as interested in ${event.title}')),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search people, posts, events...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search feature coming soon!')),
              );
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications feature coming soon!')),
    );
  }
}
