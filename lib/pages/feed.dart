import 'package:flutter/material.dart';
import 'package:shape_up_app/components/bottomNavBar.dart';
import 'package:shape_up_app/components/imageCarouselWithIndicators.dart';
import 'package:shape_up_app/models/socialServiceReponses.dart';

import '../services/SocialService.dart';

const Color kBackgroundColor = Color(0xFF191F2B);
const Color kPlaceholderColor = Colors.white24;
const EdgeInsets kDefaultPadding = EdgeInsets.symmetric(
  horizontal: 12.0,
  vertical: 8.0,
);
const EdgeInsets kCardMargin = EdgeInsets.symmetric(
  horizontal: 8.0,
  vertical: 16.0,
);
const double kStoryAvatarSize = 66.0;
const double kStoryAvatarRadius = 30.0;
const double kPostImageHeight = 250.0;

class PostModel {
  final int id;
  final String title;
  final String? imageUrl;
  int likes;
  int comments;
  int shares;
  String selectedReaction;

  PostModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.selectedReaction,
  });
}

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  // Story status - kept simple as boolean list for this example
  final List<bool> _storyStatus = [
    false, // Seu Story (visto)
    true, // Perfil 1 (não visto)
    true, // Perfil 2 (não visto)
    false, // Perfil 3 (visto)
    false, // Perfil 4 (visto)
  ];

  Future<List<PostDto>>? _postsFuture;

  @override
  void initState() {
    super.initState();

    _postsFuture = _loadPosts();
  }

  Future<List<PostDto>> _loadPosts() async {
    var posts = await SocialService.getActivityFeedAsync();

    return posts;
  }

  void _showReactionPopup(BuildContext context, int postIndex) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ReactionPopup(
            onEmojiSelected: (String emoji) {
              setState(() {
                //_posts![postIndex]. = emoji;
              });
              Navigator.of(dialogContext).pop(); // Use the dialog's context
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        title: const Text(
          'ShapeUp',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              /* TODO: Implement notifications logic */
            },
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            onPressed: () {
              /* TODO: Implement messages logic */
            },
          ),
        ],
      ),
      body: FutureBuilder<List<PostDto>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length + 1, // +1 para a seção de stories
              itemBuilder: (context, index) {
                if (index == 0) {
                  return StorySection(storyStatus: _storyStatus);
                } else {
                  final postIndex = index - 1;
                  final post =
                      posts[postIndex]; // Acessa os posts da lista recebida
                  return PostCard(
                    post: post,
                    onReactionPressed:
                        () => _showReactionPopup(context, postIndex),
                    onOptionsPressed: () {
                      // ...
                    },
                  );
                }
              },
            );
          } else {
            return const Center(child: Text('Nenhum post encontrado'));
          }
        },
      ),
    );
  }
}

// --- Story Section Widget --- (Best Practice: Extract complex UI parts)
class StorySection extends StatelessWidget {
  final List<bool> storyStatus;

  const StorySection({required this.storyStatus, super.key});

  @override
  Widget build(BuildContext context) {
    // Example labels - in a real app, these would come from user data
    final storyLabels = [
      'Seu Story',
      'Perfil 1',
      'Perfil 2',
      'Perfil 3',
      'Perfil 4',
    ];

    return Container(
      height: 120, // Height adjusted previously
      color: kBackgroundColor, // Use constant
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 4.0,
        ), // Add horizontal padding
        scrollDirection: Axis.horizontal,
        itemCount: storyStatus.length,
        itemBuilder: (context, index) {
          return StoryAvatar(
            label: storyLabels[index], // Use dynamic label
            isNotSeen: storyStatus[index],
          );
        },
      ),
    );
  }
}

// --- Story Avatar Widget ---
class StoryAvatar extends StatelessWidget {
  final String label;
  final bool isNotSeen;

  const StoryAvatar({required this.label, required this.isNotSeen, super.key});

  @override
  Widget build(BuildContext context) {
    // Define gradients as constants within the build or class scope if complex
    final Gradient seenGradient = LinearGradient(
      colors: [Colors.grey.shade600, Colors.grey.shade800],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
    final Gradient notSeenGradient = const LinearGradient(
      colors: [Colors.pinkAccent, Colors.blueAccent],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6.0,
        vertical: 4.0,
      ), // Slight adjustment
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: kStoryAvatarSize,
                height: kStoryAvatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isNotSeen ? notSeenGradient : seenGradient,
                ),
              ),
              // Consider adding placeholder/actual image logic here
              const CircleAvatar(
                radius: kStoryAvatarRadius,
                backgroundColor: Colors.grey,
                // backgroundImage: NetworkImage('URL_DA_IMAGEM_AQUI'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
            overflow: TextOverflow.ellipsis, // Good for potentially long names
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// --- Post Card Widget ---
class PostCard extends StatelessWidget {
  final PostDto post;
  final VoidCallback onReactionPressed;
  final VoidCallback onOptionsPressed;

  const PostCard({
    required this.post,
    required this.onReactionPressed,
    required this.onOptionsPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: kCardMargin, // Use constant margin
      color: kBackgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          ListTile(
            leading: CircleAvatar(
              backgroundImage: Image.network(post.publisherImageUrl).image,
              foregroundImage: Image.network(post.publisherImageUrl).image,
            ),
            title: Text(
              '${post.publisherFirstName} ${post.publisherLastName}', // Access model property
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onPressed: onOptionsPressed, // Use callback
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12.0,
            ), // Adjust padding if needed
          ),

          // Image Section
          SizedBox(
            height: 330, // Use constant
            child: post.images != null && post.images.isNotEmpty
                 ? ImageCarouselWithIndicator(imageUrls: post.images,)
                 : const Center(child: Text("No Image", style: TextStyle(color: Colors.grey))),
          ),

          SizedBox(height: 15),

          // Action Bar Section (Reactions, Comments, Shares)
          Padding(
            padding: kDefaultPadding, // Use constant padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side actions (Reaction, Likes, Comments)
                Row(
                  children: [
                    GestureDetector(
                      onTap: onReactionPressed, // Use callback
                      child: Text(
                        '', // Access model property
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Combine icon/text for semantic grouping if needed
                    Text(
                      '${20}', // Access model property
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${2}', // Access model property
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                // Right side actions (Shares)
                Row(
                  children: [
                    const Icon(
                      Icons.send_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${2}', // Access model property
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Description Section
          Padding(
            padding: const EdgeInsets.fromLTRB(
              12.0,
              12.0,
              12.0,
              12.0,
            ), // Adjusted padding
            child: Text(
              post.content, // Placeholder description
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ), // Use opacity for subtlety
            ),
          ),
        ],
      ),
    );
  }
}

// --- Reaction Popup Widget --- (Largely unchanged, already well-structured)
class ReactionPopup extends StatefulWidget {
  final Function(String) onEmojiSelected;

  const ReactionPopup({required this.onEmojiSelected, super.key});

  @override
  _ReactionPopupState createState() => _ReactionPopupState();
}

class _ReactionPopupState extends State<ReactionPopup> {
  // Could be made a constant if never changed
  final List<String> _reactionEmojis = const [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '😡',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95), // Slightly less transparent
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15), // Softer shadow
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Important for Dialog sizing
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            _reactionEmojis.map((emoji) {
              return GestureDetector(
                onTap:
                    () => widget.onEmojiSelected(emoji), // Use arrow function
                // Add InkWell or similar for visual feedback on tap if desired
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              );
            }).toList(),
      ),
    );
  }
}
