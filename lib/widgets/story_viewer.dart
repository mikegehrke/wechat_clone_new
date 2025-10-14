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
  final int _currentStoryIndex = 0;

  @override
  void initState() {
    super.initState();
    // No controller needed
  }

  @override
  Widget build(BuildContext context) {
    // StoryView package not available - simplified version
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'Story Viewer\n${widget.storyGroup.username}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    /* Original code - requires story_view package
    final storyItems = widget.storyGroup.stories.map((story) {
      switch (story.type) {
        case StoryType.image:
          return Container(); // StoryItem not available
        case StoryType.video:
          return Container();
        case StoryType.text:
          return Container();
        case StoryType.poll:
          return _buildPollStoryItem(story);
        default:
          return Container();
      }
    }).toList();

    */
  }
}
