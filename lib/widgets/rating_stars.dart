import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final bool showRating;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = Colors.amber,
    this.showRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return Icon(Icons.star, size: size, color: color);
          } else if (index < rating) {
            return Icon(Icons.star_half, size: size, color: color);
          } else {
            return Icon(Icons.star_border, size: size, color: color);
          }
        }),
        if (showRating) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.875,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
