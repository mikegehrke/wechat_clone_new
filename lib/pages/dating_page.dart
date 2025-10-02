import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../models/dating_profile.dart';
import '../services/dating_service.dart';
import '../widgets/dating_card.dart';
import '../widgets/match_dialog.dart';

class DatingPage extends StatefulWidget {
  const DatingPage({super.key});

  @override
  State<DatingPage> createState() => _DatingPageState();
}

class _DatingPageState extends State<DatingPage> {
  final CardSwiperController _controller = CardSwiperController();
  List<DatingProfile> _profiles = [];
  bool _isLoading = false;
  String? _error;
  int _currentIndex = 0;
  final String _currentUserId = 'demo_user_1'; // In real app, get from auth

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final preferences = DatingPreferences();
      final profiles = await DatingService.getPotentialMatches(
        userId: _currentUserId,
        preferences: preferences,
      );
      
      setState(() {
        _profiles = profiles;
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Dating',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettings,
          ),
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: _showMatches,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfiles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_profiles.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Card stack
        Expanded(
          child: CardSwiper(
            controller: _controller,
            cardsCount: _profiles.length,
            onSwipe: _onSwipe,
            onTap: _onTap,
            cardBuilder: (context, index, horizontalThreshold, verticalThreshold) {
              if (index >= _profiles.length) return null;
              return DatingCard(
                profile: _profiles[index],
                onTap: () => _showProfileDetails(_profiles[index]),
              );
            },
          ),
        ),
        
        // Action buttons
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'No More Profiles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check back later for new matches!',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadProfiles,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pass button
          _buildActionButton(
            icon: Icons.close,
            color: Colors.grey[600]!,
            onTap: _passProfile,
          ),
          
          // Super like button
          _buildActionButton(
            icon: Icons.star,
            color: Colors.blue,
            onTap: _superLikeProfile,
          ),
          
          // Like button
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.red,
            onTap: _likeProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (currentIndex == null) return false;

    final profile = _profiles[previousIndex];
    SwipeType swipeType;

    switch (direction) {
      case CardSwiperDirection.left:
        swipeType = SwipeType.pass;
        break;
      case CardSwiperDirection.right:
        swipeType = SwipeType.like;
        break;
      case CardSwiperDirection.top:
        swipeType = SwipeType.superLike;
        break;
      default:
        return false;
    }

    _handleSwipe(profile, swipeType);
    return true;
  }

  void _onTap(int index) {
    if (index < _profiles.length) {
      _showProfileDetails(_profiles[index]);
    }
  }

  void _passProfile() {
    if (_currentIndex < _profiles.length) {
      _controller.swipeLeft();
    }
  }

  void _superLikeProfile() {
    if (_currentIndex < _profiles.length) {
      _controller.swipeTop();
    }
  }

  void _likeProfile() {
    if (_currentIndex < _profiles.length) {
      _controller.swipeRight();
    }
  }

  Future<void> _handleSwipe(DatingProfile profile, SwipeType swipeType) async {
    try {
      final isMatch = await DatingService.swipeProfile(
        userId: _currentUserId,
        targetUserId: profile.id,
        swipeType: swipeType,
      );

      if (isMatch) {
        _showMatchDialog(profile);
      }

      setState(() {
        _currentIndex++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to swipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMatchDialog(DatingProfile profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchDialog(
        profile: profile,
        onSendMessage: () {
          Navigator.pop(context);
          _showMatches();
        },
        onKeepSwiping: () => Navigator.pop(context),
      ),
    );
  }

  void _showProfileDetails(DatingProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildProfileDetailsSheet(profile),
    );
  }

  Widget _buildProfileDetailsSheet(DatingProfile profile) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Profile content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photos
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: profile.photos.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(profile.photos[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Basic info
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${profile.name}, ${profile.age}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (profile.isVerified)
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 24,
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    profile.formattedDistance,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Bio
                  if (profile.bio.isNotEmpty) ...[
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile.bio,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Job
                  if (profile.job.isNotEmpty) ...[
                    _buildInfoRow(Icons.work, 'Job', profile.job),
                    const SizedBox(height: 8),
                  ],
                  
                  // Education
                  if (profile.education.isNotEmpty) ...[
                    _buildInfoRow(Icons.school, 'Education', profile.education),
                    const SizedBox(height: 8),
                  ],
                  
                  // Height
                  if (profile.height > 0) ...[
                    _buildInfoRow(Icons.height, 'Height', profile.formattedHeight),
                    const SizedBox(height: 8),
                  ],
                  
                  // Looking for
                  if (profile.lookingFor.isNotEmpty) ...[
                    _buildInfoRow(Icons.favorite, 'Looking for', profile.lookingFor),
                    const SizedBox(height: 16),
                  ],
                  
                  // Interests
                  if (profile.interests.isNotEmpty) ...[
                    const Text(
                      'Interests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.interests.map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DatingSettingsPage(),
      ),
    );
  }

  void _showMatches() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MatchesPage(),
      ),
    );
  }
}

// Dating Settings Page
class DatingSettingsPage extends StatefulWidget {
  const DatingSettingsPage({super.key});

  @override
  State<DatingSettingsPage> createState() => _DatingSettingsPageState();
}

class _DatingSettingsPageState extends State<DatingSettingsPage> {
  DatingPreferences _preferences = DatingPreferences();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dating Settings'),
        actions: [
          TextButton(
            onPressed: _savePreferences,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Age range
          _buildSectionTitle('Age Range'),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('Min: ${_preferences.minAge}'),
                    Slider(
                      value: _preferences.minAge.toDouble(),
                      min: 18,
                      max: 50,
                      divisions: 32,
                      onChanged: (value) {
                        setState(() {
                          _preferences = DatingPreferences(
                            minAge: value.round(),
                            maxAge: _preferences.maxAge,
                            maxDistance: _preferences.maxDistance,
                            interestedIn: _preferences.interestedIn,
                            showOnlyVerified: _preferences.showOnlyVerified,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Max: ${_preferences.maxAge}'),
                    Slider(
                      value: _preferences.maxAge.toDouble(),
                      min: 18,
                      max: 50,
                      divisions: 32,
                      onChanged: (value) {
                        setState(() {
                          _preferences = DatingPreferences(
                            minAge: _preferences.minAge,
                            maxAge: value.round(),
                            maxDistance: _preferences.maxDistance,
                            interestedIn: _preferences.interestedIn,
                            showOnlyVerified: _preferences.showOnlyVerified,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Distance
          _buildSectionTitle('Maximum Distance'),
          Text('${_preferences.maxDistance} km'),
          Slider(
            value: _preferences.maxDistance.toDouble(),
            min: 1,
            max: 100,
            divisions: 99,
            onChanged: (value) {
              setState(() {
                _preferences = DatingPreferences(
                  minAge: _preferences.minAge,
                  maxAge: _preferences.maxAge,
                  maxDistance: value.round(),
                  interestedIn: _preferences.interestedIn,
                  showOnlyVerified: _preferences.showOnlyVerified,
                );
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Show only verified
          SwitchListTile(
            title: const Text('Show only verified profiles'),
            value: _preferences.showOnlyVerified,
            onChanged: (value) {
              setState(() {
                _preferences = DatingPreferences(
                  minAge: _preferences.minAge,
                  maxAge: _preferences.maxAge,
                  maxDistance: _preferences.maxDistance,
                  interestedIn: _preferences.interestedIn,
                  showOnlyVerified: value,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _savePreferences() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved!')),
    );
    Navigator.pop(context);
  }
}

// Matches Page
class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  List<Match> _matches = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In real app, load from DatingService
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _matches = []; // Mock data would go here
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
              ? _buildEmptyState()
              : _buildMatchesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Matches Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep swiping to find your match!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final match = _matches[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/100'),
          ),
          title: const Text('Match Name'),
          subtitle: const Text('Last message...'),
          trailing: const Text('2h'),
          onTap: () {
            // Open chat
          },
        );
      },
    );
  }
}