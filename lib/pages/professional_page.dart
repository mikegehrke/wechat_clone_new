import 'package:flutter/material.dart';
import '../models/professional.dart';
import '../services/professional_service.dart';
import '../widgets/professional_post_card.dart';
import '../widgets/job_posting_card.dart';
import '../widgets/professional_profile_card.dart';
import 'professional_profile_page.dart';
import 'job_detail_page.dart';
import 'network_page.dart';

class ProfessionalPage extends StatefulWidget {
  const ProfessionalPage({super.key});

  @override
  State<ProfessionalPage> createState() => _ProfessionalPageState();
}

class _ProfessionalPageState extends State<ProfessionalPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<ProfessionalPost> _feed = [];
  List<JobPosting> _jobPostings = [];
  List<ProfessionalProfile> _networkSuggestions = [];
  bool _isLoading = false;
  String? _error;
  final String _currentUserId = 'demo_user_1'; // In real app, get from auth

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        ProfessionalService.getFeed(_currentUserId),
        ProfessionalService.getJobPostings(),
        ProfessionalService.getNetworkSuggestions(_currentUserId),
      ]);

      setState(() {
        _feed = futures[0] as List<ProfessionalPost>;
        _jobPostings = futures[1] as List<JobPosting>;
        _networkSuggestions = futures[2] as List<ProfessionalProfile>;
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
          'Professional',
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
            icon: const Icon(Icons.person_add, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NetworkPage(),
                ),
              );
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
            Tab(text: 'Jobs'),
            Tab(text: 'Network'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedTab(),
          _buildJobsTab(),
          _buildNetworkTab(),
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
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
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
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start by creating your first post!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _feed.length,
      itemBuilder: (context, index) {
        final post = _feed[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ProfessionalPostCard(
            post: post,
            onLike: () => _likePost(post),
            onShare: () => _sharePost(post),
            onComment: () => _commentOnPost(post),
          ),
        );
      },
    );
  }

  Widget _buildJobsTab() {
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
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_jobPostings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No job postings found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _jobPostings.length,
      itemBuilder: (context, index) {
        final job = _jobPostings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: JobPostingCard(
            job: job,
            onTap: () => _navigateToJob(job),
            onApply: () => _applyForJob(job),
          ),
        );
      },
    );
  }

  Widget _buildNetworkTab() {
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
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_networkSuggestions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No network suggestions',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _networkSuggestions.length,
      itemBuilder: (context, index) {
        final profile = _networkSuggestions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ProfessionalProfileCard(
            profile: profile,
            onTap: () => _navigateToProfile(profile),
            onConnect: () => _connectWithProfile(profile),
          ),
        );
      },
    );
  }

  void _createPost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'What\'s on your mind?',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
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
                const SnackBar(content: Text('Post created successfully!')),
              );
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  void _likePost(ProfessionalPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${post.isLiked ? 'Unliked' : 'Liked'} post')),
    );
  }

  void _sharePost(ProfessionalPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post shared!')),
    );
  }

  void _commentOnPost(ProfessionalPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment feature coming soon!')),
    );
  }

  void _navigateToJob(JobPosting job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailPage(job: job),
      ),
    );
  }

  void _applyForJob(JobPosting job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applied for ${job.title} at ${job.companyName}')),
    );
  }

  void _navigateToProfile(ProfessionalProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfessionalProfilePage(profile: profile),
      ),
    );
  }

  void _connectWithProfile(ProfessionalProfile profile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connection request sent to ${profile.fullName}')),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search professionals, companies, or jobs...',
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
}