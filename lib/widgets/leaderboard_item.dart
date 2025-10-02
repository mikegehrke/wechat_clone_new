import 'package:flutter/material.dart';
import '../models/game.dart';

class LeaderboardItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;

  const LeaderboardItem({
    super.key,
    required this.entry,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;
    final medalColor = _getMedalColor(rank);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTopThree ? medalColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTopThree ? medalColor.withOpacity(0.3) : Colors.grey[200]!,
          width: isTopThree ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTopThree ? medalColor : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isTopThree
                  ? Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // User avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue[100],
            child: Text(
              entry.username[0].toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.username,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isTopThree ? FontWeight.bold : FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // isVerified not in model
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      size: 14,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
                const SizedBox(height: 2),
                Text(
                  'Score: ${entry.score}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isTopThree ? medalColor.withOpacity(0.1) : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  _formatScore(entry.score),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isTopThree ? medalColor : Colors.black,
                  ),
                ),
                Text(
                  'points',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}
