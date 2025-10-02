import 'package:flutter/material.dart';
import '../models/game.dart';

class GameCategoryCard extends StatelessWidget {
  final GameCategory category;
  final VoidCallback onTap;

  const GameCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  _getCategoryEmoji(category.name),
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Category name
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // Game count
            Text(
              '${category.gameCount} games',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            
            // Popular badge
            if (category.isPopular)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getCategoryEmoji(String categoryName) {
    final emojis = {
      'Action': '🎮',
      'Adventure': '🗺️',
      'Puzzle': '🧩',
      'Racing': '🏎️',
      'Sports': '⚽',
      'Strategy': '♟️',
      'RPG': '⚔️',
      'Simulation': '🏠',
    };
    return emojis[categoryName] ?? '🎯';
  }
}