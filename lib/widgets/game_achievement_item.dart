import 'package:flutter/material.dart';
import '../models/game.dart';

class GameAchievementItem extends StatelessWidget {
  final GameAchievement achievement;

  const GameAchievementItem({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 160,
      child: Card(
        elevation: achievement.isUnlocked ? 2 : 0,
        color: achievement.isUnlocked ? Colors.white : Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: achievement.isUnlocked 
                ? Colors.amber.withOpacity(0.3) 
                : Colors.grey[300]!,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Achievement icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked 
                      ? Colors.amber[50] 
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
                  size: 30,
                  color: achievement.isUnlocked 
                      ? Colors.amber[700] 
                      : Colors.grey[400],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                achievement.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: achievement.isUnlocked ? Colors.black : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Description
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Progress or unlock status
              if (achievement.isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Unlocked',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Locked',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
