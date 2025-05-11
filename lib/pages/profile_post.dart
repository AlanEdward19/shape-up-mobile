import 'package:flutter/material.dart';
import 'package:shape_up_app/components/post_card.dart';
import 'package:shape_up_app/dtos/socialService/post_dto.dart';
import 'package:shape_up_app/services/social_service.dart';

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

  @override
  void initState() {
    super.initState();
    _posts = List.from(widget.posts);
    _scrollController = ScrollController();

    // Rola para o índice inicial após o layout ser construído
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(widget.initialIndex * 500.0); // Ajuste o valor conforme o tamanho do post
    });
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
          return PostCard(
            currentUserId: null, // Substitua pelo ID do usuário atual, se necessário
            post: post,
            currentUserReaction: null, // Substitua pela reação do usuário, se necessário
            reactionCount: post.reactionsCount,
            commentCount: post.commentsCount,
            comments: [], // Substitua pelos comentários do post, se necessário
            onReactionButtonPressed: (context) {
              // Lógica para abrir o popup de reações
            },
            onReactionSelected: (postId, reactionType) async {
              await SocialService.reactToPostAsync(postId, reactionType);
              setState(() {
                post.reactionsCount++;
              });
            },
            buildReactionIcons: (postId) {
              // Lógica para construir ícones de reação
              return const Icon(Icons.thumb_up_alt_outlined, color: Colors.grey, size: 22);
            },
            onCommentButtonPressed: () {
              // Lógica para abrir o modal de comentários
            },
            onPostDeleted: () => _handlePostDeleted(post.id),
          );
        },
      ),
    );
  }
}