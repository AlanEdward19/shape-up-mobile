import 'package:flutter/material.dart';
import 'package:shape_up_app/components/post_card.dart';
import 'package:shape_up_app/dtos/socialService/post_comment_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_reaction_dto.dart';
import 'package:shape_up_app/enums/socialService/reaction_type.dart';
import 'package:shape_up_app/services/social_service.dart';
import 'package:shape_up_app/widgets/socialService/comments/comments_modal.dart';
import '../components/reaction_popup.dart';

class ProfilePost extends StatefulWidget {
  final List<PostDto> posts;
  final int initialIndex;

  const ProfilePost({required this.posts, required this.initialIndex, Key? key}) : super(key: key);

  @override
  _ProfilePostState createState() => _ProfilePostState();
}

class _ProfilePostState extends State<ProfilePost> {
  late ScrollController _scrollController;
  late List<PostDto> _posts;
  Map<String, ReactionType?> _currentUserReactions = {};
  Map<String, List<PostReactionDto>> _allPostReactions = {};
  Map<String, List<PostCommentDto>> _allPostComments = {};

  @override
  void initState() {
    super.initState();
    _posts = List.from(widget.posts);
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(widget.initialIndex * 500.0); // Adjust based on post size
    });
  }

  Future<void> _handleReactionSelected(String postId, ReactionType selectedReaction) async {
    final currentReaction = _currentUserReactions[postId];
    final originalReactions = List<PostReactionDto>.from(_allPostReactions[postId] ?? []);
    final originalUserReaction = _currentUserReactions[postId];

    if (currentReaction == selectedReaction) {
      setState(() {
        _currentUserReactions[postId] = null;
        _allPostReactions[postId]?.removeWhere((r) => r.profileId == "currentUserId");
      });
    } else {
      setState(() {
        _currentUserReactions[postId] = selectedReaction;
        _allPostReactions[postId]?.removeWhere((r) => r.profileId == "currentUserId");
        _allPostReactions[postId]?.add(PostReactionDto(
          "currentUserId",
          DateTime.now().toIso8601String(),
          selectedReaction,
          postId,
          "temp_id_${DateTime.now().millisecondsSinceEpoch}",
        ));
      });
    }

    try {
      if (currentReaction == selectedReaction) {
        await SocialService.deleteReactionAsync(postId);
      } else {
        await SocialService.reactToPostAsync(postId, selectedReaction);
      }

      final updatedPost = await SocialService.getPostAsync(postId);
      setState(() {
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          _posts[postIndex] = updatedPost;
        }
      });
    } catch (e) {
      setState(() {
        _currentUserReactions[postId] = originalUserReaction;
        _allPostReactions[postId] = originalReactions;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating reaction: $e')),
      );
    }
  }

  void _showReactionPopup(BuildContext context, String postId) {
    final RenderBox buttonBox = context.findRenderObject() as RenderBox;
    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonBox.size;
    final screenWidth = MediaQuery.of(context).size.width;

    const double popupHeight = 70.0;
    const double popupWidth = 280.0;

    double top = buttonPosition.dy - popupHeight - 8;
    double left = buttonPosition.dx + buttonSize.width / 2 - popupWidth / 2;

    if (top < kToolbarHeight) {
      top = buttonPosition.dy + buttonSize.height - 100;
    }
    if (left < 8) left = 8;
    if (left + popupWidth > screenWidth - 8) left = screenWidth - popupWidth - 8;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (dialogContext) {
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: Material(
                type: MaterialType.transparency,
                child: ReactionPopup(
                  onEmojiSelected: (reactionType) {
                    Navigator.of(dialogContext).pop();
                    _handleReactionSelected(postId, reactionType);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadCommentsForPost(String postId) async {
    try {
      final comments = await SocialService.getPostCommentsAsync(postId);
      setState(() {
        _allPostComments[postId] = comments;
      });

      showCommentsModal(context, postId, comments);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading comments: $e')),
      );
    }
  }

  Future<void> _handlePostDeleted(String postId) async {
    setState(() {
      _posts.removeWhere((post) => post.id == postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF191F2B),
        title: const Text("Posts", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          final currentUserReaction = _currentUserReactions[post.id];

          return PostCard(
            currentUserId: "currentUserId", // Replace with actual user ID
            post: post,
            currentUserReaction: currentUserReaction,
            reactionCount: post.reactionsCount,
            commentCount: post.commentsCount,
            comments: _allPostComments[post.id] ?? [],
            onReactionButtonPressed: (buttonContext) => _showReactionPopup(buttonContext, post.id),
            onReactionSelected: _handleReactionSelected,
            buildReactionIcons: (postId) {
              final topReactions = post.topReactions;
              if (topReactions.isEmpty) {
                return const Icon(Icons.thumb_up_alt_outlined, color: Colors.grey, size: 22);
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: topReactions.take(3).map((reactionType) {
                  final emoji = reactionEmojiMap[reactionType] ?? "👍";
                  return Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }).toList(),
              );
            },
            onCommentButtonPressed: () => _loadCommentsForPost(post.id),
            onPostDeleted: () => _handlePostDeleted(post.id),
          );
        },
      ),
    );
  }
}