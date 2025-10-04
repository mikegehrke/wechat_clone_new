import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/status_service.dart';

class ViewStatusPage extends StatefulWidget {
  final List<Map<String, dynamic>> statuses;
  final int initialIndex;

  const ViewStatusPage({
    super.key,
    required this.statuses,
    this.initialIndex = 0,
  });

  @override
  State<ViewStatusPage> createState() => _ViewStatusPageState();
}

class _ViewStatusPageState extends State<ViewStatusPage> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Mark current status as viewed
    _markAsViewed();
  }

  Future<void> _markAsViewed() async {
    try {
      final currentStatus = widget.statuses[_currentIndex];
      final userId = FirebaseAuth.instance.currentUser!.uid;
      
      await StatusService.viewStatus(currentStatus['id'], userId);
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Status content
          PageView.builder(
            controller: _pageController,
            itemCount: widget.statuses.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              _markAsViewed();
            },
            itemBuilder: (context, index) {
              final status = widget.statuses[index];
              
              return GestureDetector(
                onTapUp: (details) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  if (details.globalPosition.dx < screenWidth / 2) {
                    // Tap left - previous
                    if (_currentIndex > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else {
                    // Tap right - next
                    if (_currentIndex < widget.statuses.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (status['mediaType'] == 'image')
                        Image.network(
                          status['mediaUrl'],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const CircularProgressIndicator();
                          },
                        )
                      else
                        const Icon(Icons.play_circle_outline, size: 100, color: Colors.white),
                      
                      if (status['caption'] != null && status['caption'].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            status['caption'],
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Top bar with progress indicators
          SafeArea(
            child: Column(
              children: [
                // Progress bars
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: List.generate(
                      widget.statuses.length,
                      (index) => Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: index <= _currentIndex
                                ? Colors.white
                                : Colors.white30,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // User info
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          widget.statuses[_currentIndex]['userName'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.statuses[_currentIndex]['userName'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getTimeAgo(widget.statuses[_currentIndex]['timestamp']),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return '';
    
    final DateTime dateTime = (timestamp as dynamic).toDate();
    final difference = DateTime.now().difference(dateTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
