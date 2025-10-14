import 'package:flutter/material.dart';
import '../models/story.dart';
import '../widgets/story_circle.dart';
import '../widgets/story_viewer.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  List<StoryGroup> _storyGroups = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // In real app, load from StoryService
      // For demo, create mock data
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _storyGroups = _createMockStoryGroups();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<StoryGroup> _createMockStoryGroups() {
    return [
      StoryGroup(
        userId: 'user1',
        username: 'alice_johnson',
        userAvatar: 'https://via.placeholder.com/100x100/FF6B6B/FFFFFF?text=A',
        hasUnviewedStories: true,
        stories: [
          Story(
            id: '1',
            userId: 'user1',
            username: 'alice_johnson',
            userAvatar:
                'https://via.placeholder.com/100x100/FF6B6B/FFFFFF?text=A',
            contentUrl:
                'https://via.placeholder.com/400x600/FF6B6B/FFFFFF?text=Story+1',
            type: StoryType.image,
            caption: 'Beautiful sunset! 🌅',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          Story(
            id: '2',
            userId: 'user1',
            username: 'alice_johnson',
            userAvatar:
                'https://via.placeholder.com/100x100/FF6B6B/FFFFFF?text=A',
            contentUrl:
                'https://via.placeholder.com/400x600/4ECDC4/FFFFFF?text=Story+2',
            type: StoryType.image,
            caption: 'Coffee time ☕',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      StoryGroup(
        userId: 'user2',
        username: 'bob_smith',
        userAvatar: 'https://via.placeholder.com/100x100/45B7D1/FFFFFF?text=B',
        hasUnviewedStories: false,
        stories: [
          Story(
            id: '3',
            userId: 'user2',
            username: 'bob_smith',
            userAvatar:
                'https://via.placeholder.com/100x100/45B7D1/FFFFFF?text=B',
            contentUrl:
                'https://via.placeholder.com/400x600/45B7D1/FFFFFF?text=Story+3',
            type: StoryType.video,
            caption: 'Amazing dance moves! 💃',
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
            duration: const Duration(seconds: 10),
          ),
        ],
      ),
      StoryGroup(
        userId: 'user3',
        username: 'carol_davis',
        userAvatar: 'https://via.placeholder.com/100x100/96CEB4/FFFFFF?text=C',
        hasUnviewedStories: true,
        stories: [
          Story(
            id: '4',
            userId: 'user3',
            username: 'carol_davis',
            userAvatar:
                'https://via.placeholder.com/100x100/96CEB4/FFFFFF?text=C',
            contentUrl:
                'https://via.placeholder.com/400x600/96CEB4/FFFFFF?text=Poll:+Best+Food?',
            type: StoryType.poll,
            caption: 'Best food?',
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
      ),
      StoryGroup(
        userId: 'user4',
        username: 'david_wilson',
        userAvatar: 'https://via.placeholder.com/100x100/FFEAA7/FFFFFF?text=D',
        hasUnviewedStories: false,
        stories: [
          Story(
            id: '5',
            userId: 'user4',
            username: 'david_wilson',
            userAvatar:
                'https://via.placeholder.com/100x100/FFEAA7/FFFFFF?text=D',
            contentUrl:
                'https://via.placeholder.com/400x600/FFEAA7/000000?text=Hello+World!',
            type: StoryType.text,
            caption: 'Hello World!',
            createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Stories', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _showCreateStoryOptions,
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
            const Icon(Icons.error_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadStories, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Stories header
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Add story button
              _buildAddStoryButton(),
              const SizedBox(width: 16),
              // Stories list
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _storyGroups.length,
                  itemBuilder: (context, index) {
                    final storyGroup = _storyGroups[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: StoryCircle(
                        storyGroup: storyGroup,
                        onTap: () => _viewStoryGroup(storyGroup),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Stories content
        Expanded(
          child: _storyGroups.isEmpty
              ? _buildEmptyState()
              : _buildStoriesGrid(),
        ),
      ],
    );
  }

  Widget _buildAddStoryButton() {
    return GestureDetector(
      onTap: _showCreateStoryOptions,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.grey[800],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your Story',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.camera_alt_outlined,
            size: 80,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Stories Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Share your first story!',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateStoryOptions,
            icon: const Icon(Icons.add),
            label: const Text('Create Story'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoriesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _storyGroups.length,
      itemBuilder: (context, index) {
        final storyGroup = _storyGroups[index];
        return _buildStoryCard(storyGroup);
      },
    );
  }

  Widget _buildStoryCard(StoryGroup storyGroup) {
    final firstStory = storyGroup.stories.first;

    return GestureDetector(
      onTap: () => _viewStoryGroup(storyGroup),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(firstStory.contentUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: NetworkImage(storyGroup.userAvatar),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        storyGroup.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (storyGroup.hasUnviewedStories)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),

              // Story info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstStory.caption ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      firstStory.timeAgo,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewStoryGroup(StoryGroup storyGroup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryViewer(
          storyGroup: storyGroup,
          onStoryViewed: (storyId) {
            // Mark story as viewed
            setState(() {
              final storyIndex = storyGroup.stories.indexWhere(
                (story) => story.id == storyId,
              );
              if (storyIndex != -1) {
                storyGroup.stories[storyIndex] = storyGroup.stories[storyIndex]
                    .copyWith(isViewed: true);
              }
            });
          },
        ),
      ),
    );
  }

  void _showCreateStoryOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Create Story',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Camera'),
              subtitle: const Text('Take a photo or video'),
              onTap: () {
                Navigator.pop(context);
                _openCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('Gallery'),
              subtitle: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _openGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.orange),
              title: const Text('Text'),
              subtitle: const Text('Create a text story'),
              onTap: () {
                Navigator.pop(context);
                _createTextStory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.poll, color: Colors.purple),
              title: const Text('Poll'),
              subtitle: const Text('Create a poll'),
              onTap: () {
                Navigator.pop(context);
                _createPollStory();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _openCamera() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera feature coming soon!')),
    );
  }

  void _openGallery() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery feature coming soon!')),
    );
  }

  void _createTextStory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TextStoryCreator()),
    );
  }

  void _createPollStory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PollStoryCreator()),
    );
  }
}

// Text Story Creator
class TextStoryCreator extends StatefulWidget {
  const TextStoryCreator({super.key});

  @override
  State<TextStoryCreator> createState() => _TextStoryCreatorState();
}

class _TextStoryCreatorState extends State<TextStoryCreator> {
  final TextEditingController _textController = TextEditingController();
  Color _backgroundColor = Colors.black;
  Color _textColor = Colors.white;
  double _fontSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Text Story', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _saveTextStory,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: TextField(
                    controller: _textController,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: _fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Type your story...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Background colors
          Row(
            children: [
              const Text('Background:', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 16),
              ...Colors.primaries.map(
                (color) => GestureDetector(
                  onTap: () => setState(() => _backgroundColor = color),
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _backgroundColor == color
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Text color
          Row(
            children: [
              const Text('Text Color:', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 16),
              ...Colors.primaries.map(
                (color) => GestureDetector(
                  onTap: () => setState(() => _textColor = color),
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: _textColor == color
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Font size
          Row(
            children: [
              const Text('Size:', style: TextStyle(color: Colors.white)),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 16,
                  max: 48,
                  onChanged: (value) => setState(() => _fontSize = value),
                  activeColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveTextStory() {
    if (_textController.text.trim().isEmpty) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Text story created!')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

// Poll Story Creator
class PollStoryCreator extends StatefulWidget {
  const PollStoryCreator({super.key});

  @override
  State<PollStoryCreator> createState() => _PollStoryCreatorState();
}

class _PollStoryCreatorState extends State<PollStoryCreator> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _option1Controller = TextEditingController();
  final TextEditingController _option2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Poll'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _savePollStory),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _option1Controller,
              decoration: const InputDecoration(
                labelText: 'Option 1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _option2Controller,
              decoration: const InputDecoration(
                labelText: 'Option 2',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _savePollStory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Create Poll Story'),
            ),
          ],
        ),
      ),
    );
  }

  void _savePollStory() {
    if (_questionController.text.trim().isEmpty ||
        _option1Controller.text.trim().isEmpty ||
        _option2Controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Poll story created!')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    super.dispose();
  }
}
