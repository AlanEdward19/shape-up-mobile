import 'package:flutter/material.dart';
import './story_avatar.dart';

class StorySection extends StatelessWidget {
  final List<bool> storyStatus;


  const StorySection({
    required this.storyStatus,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Remover labels fixos e usar dados reais (ex: this.stories)
    final storyLabels = ['Seu Story', 'Perfil 1', 'Perfil 2', 'Perfil 3', 'Perfil 4'];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        scrollDirection: Axis.horizontal,
        itemCount: storyStatus.length,
        itemBuilder: (context, index) {
          return StoryAvatar(
            label: storyLabels[index],
            isNotSeen: storyStatus[index],
          );
        },
      ),
    );
  }
}