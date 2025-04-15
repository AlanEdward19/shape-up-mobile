import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shape_up_app/components/image_carousel_with_indicators.dart';
import 'package:shape_up_app/dtos/socialService/post_comment_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_dto.dart';
import 'package:shape_up_app/enums/socialService/reaction_type.dart';
import 'package:shape_up_app/widgets/socialService/comments/comments_modal.dart';

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


class PostCard extends StatelessWidget {
  final PostDto post;
  final ReactionType? currentUserReaction;
  final int reactionCount;
  final int commentCount;
  final List<PostCommentDto> comments;
  final Function(BuildContext) onReactionButtonPressed;
  final Function(String, ReactionType) onReactionSelected;
  final VoidCallback onOptionsPressed;
  final Widget Function(String) buildReactionIcons;

  const PostCard({
    required this.post,
    required this.currentUserReaction,
    required this.reactionCount,
    required this.commentCount,
    required this.comments,
    required this.onReactionButtonPressed,
    required this.onOptionsPressed,
    required this.onReactionSelected,
    required this.buildReactionIcons,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String displayEmoji;
    final Color displayColor;

    if (currentUserReaction != null) {
      displayEmoji = reactionEmojiMap[currentUserReaction] ?? kDefaultReactionEmoji;
      displayColor = Colors.blue;
    } else {
      displayEmoji = kDefaultReactionEmoji;
      displayColor = Colors.grey;
    }


    return Card(
      margin: kCardMargin,
      color: kBackgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: kPlaceholderColor,
              backgroundImage: NetworkImage(post.publisherImageUrl),
              onBackgroundImageError: (exception, stackTrace) {
                if (kDebugMode) print("Erro ao carregar imagem do perfil: $exception");
              },
            ),
            title: Text(
              '${post.publisherFirstName} ${post.publisherLastName}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onPressed: onOptionsPressed,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),

          if (post.images.isNotEmpty)
            SizedBox(
              height: kPostImageHeight,
              child: ImageCarouselWithIndicator(imageUrls: post.images),
            )
          else
            const SizedBox(height: 10), // Espaço se não houver imagem

          Padding(
            padding: kDefaultPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Builder(
                        builder: (buttonContext) {
                          return InkWell(
                            onTap: () {
                              if (currentUserReaction != null) {
                                onReactionSelected(post.id, currentUserReaction!);
                              } else {
                                onReactionSelected(post.id, ReactionType.like);
                              }
                            },
                            onLongPress: () {
                              onReactionButtonPressed(buttonContext);
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                              child: buildReactionIcons(post.id),
                            ),
                          );
                        }
                    ),
                    const SizedBox(width: 6),

                    Text(
                      '$reactionCount', // Mostra a contagem total
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 16),

                    // Ícone e Contagem de Comentários (TODO: Adicionar contagem real)
                    IconButton(
                      icon : const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                      onPressed: (){
                        showCommentsModal(context, post.id, comments);
                      },
                    ),
                    const SizedBox(width: 6),

                    // Quantidade de Comentários
                    Text(
                      '$commentCount',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.send_outlined, // Ou Icons.share
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '0',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),

              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: Text(
              post.content,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}