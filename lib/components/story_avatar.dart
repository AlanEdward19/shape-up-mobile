import 'package:flutter/material.dart';

const double kStoryAvatarSize = 66.0;
const double kStoryAvatarRadius = 30.0;

class StoryAvatar extends StatelessWidget {
  final String label;
  final bool isNotSeen;

  const StoryAvatar({
    required this.label,
    required this.isNotSeen,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final Gradient seenGradient = LinearGradient(
      colors: [Colors.grey.shade600, Colors.grey.shade800],
      begin: Alignment.topRight, end: Alignment.bottomLeft,
    );
    final Gradient notSeenGradient = const LinearGradient(
      colors: [Colors.pinkAccent, Colors.blueAccent],
      begin: Alignment.topRight, end: Alignment.bottomLeft,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: kStoryAvatarSize, height: kStoryAvatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isNotSeen ? notSeenGradient : seenGradient,
                ),
              ),
              CircleAvatar(
                radius: kStoryAvatarRadius,
                backgroundColor: Colors.grey, // Placeholder
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: kStoryAvatarSize + 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center, // Centralizar texto
            ),
          ),
        ],
      ),
    );
  }
}