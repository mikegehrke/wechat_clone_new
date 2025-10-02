import 'package:flutter/material.dart';
import '../models/social.dart';

class SocialUserCard extends StatelessWidget {
  final SocialUser user;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;
  final VoidCallback? onMessage;

  const SocialUserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onFollow,
    this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.avatarUrl.isNotEmpty
                        ? NetworkImage(user.avatarUrl)
                        : null,
                    backgroundColor: Colors.blue[100],
                    child: user.avatarUrl.isEmpty
                        ? Text(
                            user.displayName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  // isOnline not in model
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ],
                      ],
                    ),
                    if (user.bio?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.bio!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStat('Posts', user.postsCount),
                        const SizedBox(width: 16),
                        _buildStat('Followers', _formatCount(user.followersCount)),
                        const SizedBox(width: 16),
                        _buildStat('Following', _formatCount(user.followingCount)),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Follow button
              if (onFollow != null)
                ElevatedButton(
                  onPressed: onFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: false
                        ? Colors.grey[300]
                        : const Color(0xFF07C160),
                    foregroundColor: false
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Follow'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, dynamic value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
