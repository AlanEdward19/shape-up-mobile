import 'package:shape_up_app/components/search_bar.dart' as SearchBar;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shape_up_app/dtos/notificationService/notification_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_comment_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_reaction_dto.dart';
import 'package:shape_up_app/dtos/socialService/simplified_profile_dto.dart';
import 'package:shape_up_app/enums/notificationService/notification_topic.dart';
import 'package:shape_up_app/enums/socialService/reaction_type.dart';
import 'package:shape_up_app/enums/socialService/post_visibility.dart';
import 'package:shape_up_app/pages/chat.dart';
import 'package:shape_up_app/pages/notifications.dart';
import 'package:shape_up_app/pages/profile.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/notification_service.dart';
import 'package:shape_up_app/services/social_service.dart';
import 'package:shape_up_app/widgets/socialService/post/post_creation_section.dart';
import '../components/post_card.dart';
import '../components/reaction_popup.dart';
import '../components/story_section.dart';
import '../widgets/socialService/comments/comments_modal.dart';

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
  List<SimplifiedProfileDto> _searchResults = [];
  SimplifiedProfileDto? _currentUser;
  String? _error;
  List<PostDto> _posts = [];
  int _unreadNotifications = 0;
  int _unreadMessages = 0;

  Map<String, ReactionType?> _currentUserReactions = {};
  Map<String, List<PostReactionDto>> _allPostReactions = {};
  Map<String, List<PostCommentDto>> _allPostComments = {};

  final List<bool> _storyStatus = [
    false, true, true, false, false,
  ];

  String _currentUserId = '';
  PostVisibility? selectedVisibility = PostVisibility.public; // Variável de instância

  Future<void> _searchProfiles(String query) async {
    if (query.isNotEmpty) {
      try {
        final results = await SocialService.searchProfileByNameAsync(query);
        setState(() {
          _searchResults = results;
        });
      } catch (e) {
        if (kDebugMode) {
          print("Erro ao buscar perfis: $e");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar perfis: $e')),
        );
      }
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeAndLoadFeed();
    _listenToNotifications();
  }

  Future<void> _getUserInfo() async {
    _currentUser = await SocialService.viewProfileSimplifiedAsync(_currentUserId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reloadUnreadNotifications();
  }

  void _reloadUnreadNotifications() {
    setState(() {
      var notifications = NotificationService.getNotifications();

      _unreadMessages = notifications.where((notification) => notification.topic == NotificationTopic.Comment).length;
      _unreadNotifications = notifications.where((notification) => notification.topic != NotificationTopic.Comment).length;
    });
  }

  void _listenToNotifications() {
    NotificationService.notificationStream.listen((notification) {
      setState(() {
        _reloadUnreadNotifications();
      });
    });
  }

  Future<void> _initializeAndLoadFeed() async {
    try {
      _currentUserId = await AuthenticationService.getProfileId();
      if (_currentUserId.isNotEmpty) {
        await _getUserInfo();
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
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final posts = await SocialService.getActivityFeedAsync();

      setState(() {
        _posts = posts;
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

    if (currentReaction == selectedReaction) {
      setState(() {
        _currentUserReactions[postId] = null;
        _allPostReactions[postId]?.removeWhere((r) => r.profileId == _currentUserId);
      });
    } else {
      setState(() {
        _currentUserReactions[postId] = selectedReaction;
        _allPostReactions[postId]?.removeWhere((r) => r.profileId == _currentUserId);
        _allPostReactions[postId]?.add(PostReactionDto(
          _currentUserId,
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

      // Buscar o post atualizado
      final updatedPost = await SocialService.getPostAsync(postId);

      // Atualizar o post na lista
      setState(() {
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          _posts[postIndex] = updatedPost;
        }
      });
    } catch (e) {
      // Reverter alterações em caso de erro
      setState(() {
        _currentUserReactions[postId] = originalUserReaction;
        _allPostReactions[postId] = originalReactions;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao ${currentReaction == selectedReaction ? "remover" : "salvar"} reação: ${e.toString().replaceFirst("Exception: ", "")}')),
        );
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

  Future<void> _loadCommentsForPost(String postId) async {
    try {
      final comments = await SocialService.getPostCommentsAsync(postId);
      setState(() {
        _allPostComments[postId] = comments;
      });

      showCommentsModal(context, postId, comments);
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao carregar comentários para o post $postId: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar comentários: $e')),
      );
    }
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
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: Colors.white),
                if (_unreadNotifications > 0)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$_unreadNotifications',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const Notifications()),
              );
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.message, color: Colors.white),
                if (_unreadMessages > 0)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '$_unreadMessages',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const Chat()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBar.SearchBar(onSearch: _searchProfiles),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final profile = _searchResults[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(profile.imageUrl),
                    ),
                    title: Text(
                      '${profile.firstName} ${profile.lastName}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Profile(profileId: profile.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          if (_searchResults.isEmpty) Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    } else if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.white)));
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
              return Column(
                children: [
                  StorySection(storyStatus: _storyStatus),
                  const SizedBox(height: 16),
                  const PostCreationSection(),
                ],
              );
            } else {
              final postIndex = index - 1;
              if (postIndex >= _posts.length) return const SizedBox.shrink();

              final post = _posts[postIndex];
              final currentUserReaction = _currentUserReactions[post.id];

              return PostCard(
                currentUserId: _currentUserId,
                post: post,
                currentUserReaction: currentUserReaction,
                reactionCount: post.reactionsCount,
                commentCount: post.commentsCount,
                comments: [],
                onReactionButtonPressed: (buttonContext) => _showReactionPopup(buttonContext, post.id),
                onReactionSelected: _handleReactionSelected,
                buildReactionIcons: (postId) => _buildReactionIconsFromPost(post),
                onCommentButtonPressed: () => _loadCommentsForPost(post.id),
                onPostDeleted: _loadFeedData
              );
            }
          },
        ),
      );
    }
  }

  Widget _buildReactionIconsFromPost(PostDto post) {
    final topReactions = post.topReactions;

    if (topReactions.isEmpty) {
      return const Icon(Icons.thumb_up_alt_outlined, color: Colors.grey, size: 22);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: topReactions.take(3).map((reactionType) {
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