import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shape_up_app/dtos/socialService/post_comment_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_reaction_dto.dart';
import 'package:shape_up_app/enums/socialService/reaction_type.dart';
import 'package:shape_up_app/pages/chat.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/social_service.dart';
import '../components/post_card.dart';
import '../components/reaction_popup.dart';
import '../components/story_section.dart';
import 'dart:collection';

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

const double kPostImageHeight = 330.0;
const ReactionType kDefaultReactionType = ReactionType.like;
String kDefaultReactionEmoji = reactionEmojiMap[kDefaultReactionType] ?? "👍";


class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  bool _isLoading = true;
  String? _error;
  List<PostDto> _posts = [];

  Map<String, ReactionType?> _currentUserReactions = {};
  Map<String, List<PostReactionDto>> _allPostReactions = {};
  Map<String, List<PostCommentDto>> _allPostComments = {};

  final List<bool> _storyStatus = [
    false, true, true, false, false,
  ];

  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _initializeAndLoadFeed();
  }

  Future<void> _initializeAndLoadFeed() async {
    try {
      _currentUserId = await AuthenticationService.getProfileId();
      if (_currentUserId.isNotEmpty) {
        await _loadFeedData();
      }
    } catch (e) {
      setState(() {
        _error = "Erro ao inicializar: $e";
        _isLoading = false;
      });
    }
  }


  Future<void> _loadFeedData() async {
    if (_currentUserId.isEmpty) {
      try {
        _currentUserId = await AuthenticationService.getProfileId();
      } catch (e) {
        setState(() {
          _error = "Erro ao obter ID do usuário: $e";
          _isLoading = false;
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final posts = await SocialService.getActivityFeedAsync();


      Map<String, ReactionType?> userReactions = {};
      Map<String, List<PostReactionDto>> allReactions = {};
      Map<String, List<PostCommentDto>> allComments = {};

      for (var post in posts) {
        try {
          final results = await Future.wait([
            SocialService.getPostReactionsAsync(post.id),
            SocialService.getPostCommentsAsync(post.id),
          ]);

          final postReactions = results[0] as List<PostReactionDto>;
          final postComments = results[1] as List<PostCommentDto>;

          allReactions[post.id] = postReactions;
          allComments[post.id] = postComments;

          try {
            userReactions[post.id] = postReactions
                .firstWhere((r) => r.profileId == _currentUserId)
                .reactionType;
          } catch (e) {
            userReactions[post.id] = null;
          }

        } catch (e) {
          if (kDebugMode) {
            print("Erro ao carregar dados para post ${post.id}: $e");
          }
          allReactions[post.id] = [];
          allComments[post.id] = [];
          userReactions[post.id] = null;
        }
      }


      setState(() {
        _posts = posts;
        _currentUserReactions = userReactions;
        _allPostReactions = allReactions;
        _allPostComments = allComments;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _error = "Erro ao carregar feed: $e";
        _isLoading = false;
      });
    }
  }


  Future<void> _handleReactionSelected(String postId, ReactionType selectedReaction) async {
    final currentReaction = _currentUserReactions[postId];
    final originalReactions = List<PostReactionDto>.from(_allPostReactions[postId] ?? []);
    final originalUserReaction = _currentUserReactions[postId];

    setState(() {
      if (currentReaction == selectedReaction) {
        _currentUserReactions[postId] = null;
        _allPostReactions[postId]?.removeWhere((r) => r.profileId == _currentUserId);
      } else {
        _currentUserReactions[postId] = selectedReaction;
        _allPostReactions[postId]?.removeWhere((r) => r.profileId == _currentUserId);
        _allPostReactions[postId]?.add(PostReactionDto(
            _currentUserId,
            DateTime.now().toIso8601String(), // Data/hora temporária
            selectedReaction,
            postId,
            "temp_id_${DateTime.now().millisecondsSinceEpoch}" // ID temporário
        ));
      }
      _allPostReactions[postId]?.sort((a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
    });

    try {
      if (currentReaction == selectedReaction) {
        await SocialService.deleteReactionAsync(postId);
      } else {
        await SocialService.reactToPostAsync(postId, selectedReaction);
      }

      final updatedReactions = await SocialService.getPostReactionsAsync(postId);
      setState(() {
        _allPostReactions[postId] = updatedReactions;
        try {
          _currentUserReactions[postId] = updatedReactions
              .firstWhere((r) => r.profileId == _currentUserId)
              .reactionType;
        } catch (e) {
          _currentUserReactions[postId] = null;
        }
        _allPostReactions[postId]?.sort((a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));
      });

    } catch (e) {
      setState(() {
        _currentUserReactions[postId] = originalUserReaction;
        _allPostReactions[postId] = originalReactions;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao ${currentReaction == selectedReaction ? "remover" : "salvar"} reação: ${e.toString().replaceFirst("Exception: ", "")}')),
        );
      }
      if (kDebugMode) {
        print("Erro ao atualizar reação para post $postId: $e");
      }
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

    // Ajustar para não sair da tela
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
                )
            ),
          ],
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
        title: const Text('ShapeUp', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () { /* TODO: Implement notifications logic */ },
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const Chat()),
            );},
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    } else if (_error != null) {
      return Center();
    } else if (_posts.isEmpty) {
      return Center();
    } else {
      return RefreshIndicator(
        onRefresh: _loadFeedData,
        color: Colors.white,
        backgroundColor: kBackgroundColor.withOpacity(0.8),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16.0),
          itemCount: _posts.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return StorySection(storyStatus: _storyStatus);
            } else {
              final postIndex = index - 1;
              if (postIndex >= _posts.length) return const SizedBox.shrink();

              final post = _posts[postIndex];
              final currentUserReaction = _currentUserReactions[post.id];
              final reactionsList = _allPostReactions[post.id] ?? [];
              final commentsList = _allPostComments[post.id] ?? [];
              final reactionCount = reactionsList.length;
              final commentCount = commentsList.length;

              return PostCard(
                post: post,
                currentUserReaction: currentUserReaction,
                reactionCount: reactionCount,
                commentCount: commentCount,
                comments: commentsList,
                onReactionButtonPressed: (buttonContext) => _showReactionPopup(buttonContext, post.id),
                onReactionSelected: _handleReactionSelected,
                buildReactionIcons: _buildReactionIcons,
                onOptionsPressed: () { /* TODO: Implement options logic */ },
              );
            }
          },
        ),
      );
    }
  }

  Widget _buildReactionIcons(String postId) {
    final reactions = _allPostReactions[postId] ?? [];

    if (reactions.isEmpty) {
      return const Icon(Icons.thumb_up_alt_outlined, color: Colors.grey, size: 22);
    }

    reactions.sort((a, b) {
      try {
        return DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt));
      } catch (_) {
        return 0;
      }
    });

    final uniqueRecentTypes = LinkedHashSet<ReactionType>(
      equals: (a, b) => a == b,
      hashCode: (a) => a.hashCode,
    );
    for (var reaction in reactions) {
      uniqueRecentTypes.add(reaction.reactionType);
    }

    final topRecentTypes = uniqueRecentTypes.take(3).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: topRecentTypes.map((reactionType) {
        final emoji = reactionEmojiMap[reactionType] ?? kDefaultReactionEmoji;
        return Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
        );
      }).toList(),
    );
  }
}