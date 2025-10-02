import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import '../models/story.dart';

class StoryViewer extends StatefulWidget {
  final StoryGroup storyGroup;
  final Function(String) onStoryViewed;

  const StoryViewer({
    super.key,
    required this.storyGroup,
    required this.onStoryViewed,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  // StoryItemController not available
  int _currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    // No controller needed
  }

  @override
  Widget build(BuildContext context) {
    final storyItems = widget.storyGroup.stories.map((story) {
      switch (story.type) {
        case StoryType.image:
          return StoryItem.pageImage(
            url: story.contentUrl,
            controller: _controller,
            caption: story.caption != null ? Text(story.caption!) : null,
            imageFit: BoxFit.cover,
          );
        case StoryType.video:
          return StoryItem.pageVideo(
            story.contentUrl,
            controller: _controller,
            caption: story.caption != null ? Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                story.caption!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ) : null,
            imageFit: BoxFit.cover,
          );
        case StoryType.text:
          return StoryItem.pageImage(
            url: story.contentUrl,
            controller: _controller,
            caption: story.caption != null ? Text(story.caption!) : null,
            imageFit: BoxFit.cover,
          );
        case StoryType.poll:
          return _buildPollStoryItem(story);
        default:
          return StoryItem.pageImage(
            url: story.contentUrl,
            controller: _controller,
            caption: story.caption != null ? Text(story.caption!) : null,
            imageFit: BoxFit.cover,
          );
      }
    }).toList();

    return Scaffold(
      body: StoryView(
        storyItems: storyItems.cast<StoryItem>(),
        controller: _controller,
        onComplete: () {
          Navigator.pop(context);
        },
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        },
        onStoryShow: (storyItem, index) {
          _currentStoryIndex = index;
          widget.onStoryViewed(widget.storyGroup.stories[index].id);
        },
        indicatorColor: Colors.white,
        indicatorForegroundColor: Colors.grey[400],
        progressPosition: ProgressPosition.top,
        repeat: false,
        inline: false,
      ),
    );
  }

  Widget _buildPollStoryItem(Story story) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(story.contentUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                story.caption ?? 'Poll',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildPollOption('Option 1', Colors.red),
              const SizedBox(height: 20),
              _buildPollOption('Option 2', Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPollOption(String option, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voted for $option')),
        );
      },
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Center(
          child: Text(
            option,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}