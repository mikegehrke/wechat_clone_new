import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/channels_service.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Following'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFollowingTab(),
          _buildDiscoverTab(),
        ],
      ),
    );
  }

  Widget _buildFollowingTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ChannelsService.getFollowedChannelsStream(_currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final channels = snapshot.data ?? [];

        if (channels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.campaign, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No channels yet'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('Discover Channels'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: channels.length,
          itemBuilder: (context, index) {
            final channel = channels[index];
            return _buildChannelCard(channel, isFollowing: true);
          },
        );
      },
    );
  }

  Widget _buildDiscoverTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ChannelsService.discoverChannels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final channels = snapshot.data ?? [];

        return ListView.builder(
          itemCount: channels.length,
          itemBuilder: (context, index) {
            final channel = channels[index];
            final isFollowing = (channel['followers'] as List).contains(_currentUserId);
            return _buildChannelCard(channel, isFollowing: isFollowing);
          },
        );
      },
    );
  }

  Widget _buildChannelCard(Map<String, dynamic> channel, {required bool isFollowing}) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            channel['name'][0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(channel['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(channel['description']),
            const SizedBox(height: 4),
            Text(
              '${channel['followerCount']} followers • ${channel['postCount']} posts',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () async {
            if (isFollowing) {
              await ChannelsService.unfollowChannel(channel['id'], _currentUserId);
            } else {
              await ChannelsService.followChannel(channel['id'], _currentUserId);
            }
            setState(() {});
          },
          child: Text(isFollowing ? 'Unfollow' : 'Follow'),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/channel-detail',
            arguments: channel['id'],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
