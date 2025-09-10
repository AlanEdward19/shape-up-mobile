import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shape_up_app/enums/socialService/reaction_type.dart';

class ReactionPopup extends StatelessWidget {
  final Function(ReactionType) onEmojiSelected;
  final emojiSize;

  const ReactionPopup({required this.onEmojiSelected, super.key, this.emojiSize});

  static final Map<String, ReactionType> _emojiToReactionType = {
    for (var entry in reactionEmojiMap.entries) entry.value : entry.key
  };

  @override
  Widget build(BuildContext context) {
    final List<String> reactionEmojis = reactionEmojiMap.values.toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: reactionEmojis.map((emoji) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: InkWell(
              onTap: () {
                final reactionType = _emojiToReactionType[emoji];
                if (reactionType != null) {
                  onEmojiSelected(reactionType);
                } else {
                  if (kDebugMode) print("Erro: Emoji '$emoji' não mapeado para ReactionType.");
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Text(
                emoji,
                style: TextStyle(fontSize: emojiSize),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}