import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shape_up_app/components/image_carousel_with_indicators.dart';
import 'package:shape_up_app/components/personalized_circle_avatar.dart';
import 'package:shape_up_app/dtos/socialService/post_comment_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_dto.dart';
import 'package:shape_up_app/enums/socialService/post_visibility.dart';
import 'package:shape_up_app/enums/socialService/reaction_type.dart';
import 'package:shape_up_app/pages/profile.dart';
import 'package:shape_up_app/services/social_service.dart';
import 'package:shape_up_app/widgets/socialService/comments/comments_modal.dart';

const Color kBackgroundColor = Color(0xFF101827);
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
  final String? currentUserId;
  final PostDto post;
  final ReactionType? currentUserReaction;
  final int reactionCount;
  final int commentCount;
  final List<PostCommentDto> comments;
  final Function(BuildContext) onReactionButtonPressed;
  final Function(String, ReactionType) onReactionSelected;
  final Widget Function(String) buildReactionIcons;
  final VoidCallback onCommentButtonPressed;
  final VoidCallback? onPostDeleted;

  void showEditPostModal(BuildContext context, PostDto post, VoidCallback onPostUpdated) {
    final TextEditingController contentController = TextEditingController(text: post.content);
    PostVisibility selectedVisibility = post.visibility;
    List<String> currentImages = List.from(post.images);
    List<String> newImages = [];
    final ImagePicker imagePicker = ImagePicker();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Editar Postagem",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: contentController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Texto da postagem",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<PostVisibility>(
                    value: selectedVisibility,
                    dropdownColor: kBackgroundColor,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Visibilidade",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    items: PostVisibility.values.map((visibility) {
                      return DropdownMenuItem(
                        value: visibility,
                        child: Text(visibilityToStringMap[visibility] ?? ""),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedVisibility = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Imagens",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...currentImages.map((image) {
                        return Stack(
                          children: [
                            Image.network(image, width: 100, height: 100, fit: BoxFit.cover),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    currentImages.remove(image);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      ...newImages.map((image) {
                        return Stack(
                          children: [
                            Image.file(File(image), width: 100, height: 100, fit: BoxFit.cover),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    newImages.remove(image);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () async {
                          final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              newImages.add(pickedFile.path);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await SocialService.editPostAsync(post.id, contentController.text.trim(), selectedVisibility);

                        if (newImages.isNotEmpty || post.images.length != currentImages.length) {
                          List<String> filesToKeep = currentImages.map((e) => e.split('/').last.split('.').first.toUpperCase()).toList();
                          await SocialService.uploadFilesAsync(post.id, newImages, filesToKeep);
                        }
                        Navigator.of(context).pop();
                        onPostUpdated();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erro ao editar postagem: $e")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Salvar Alterações"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  const PostCard({
    this.currentUserId,
    required this.post,
    required this.currentUserReaction,
    required this.reactionCount,
    required this.commentCount,
    required this.comments,
    required this.onReactionButtonPressed,
    required this.onReactionSelected,
    required this.buildReactionIcons,
    required this.onCommentButtonPressed,
    this.onPostDeleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color displayColor = post.hasUserReacted ? Colors.blue : Colors.white;

    return Card(
      margin: kCardMargin,
      color: kBackgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Profile(profileId: post.publisherId),
                  ),
                );
              },
              child: personalizedCircleAvatar(
                post.publisherImageUrl,
                '${post.publisherFirstName} ${post.publisherLastName}',
                20,
              ),
            ),
            title: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Profile(profileId: post.publisherId),
                  ),
                );
              },
              child: Text(
                '${post.publisherFirstName} ${post.publisherLastName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onSelected: (value) async {
                if (value == 'edit') {
                  showEditPostModal(context, post, onPostDeleted!);
                } else if (value == 'delete') {
                  try {
                    await SocialService.deletePostAsync(post.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post excluído com sucesso!')),
                    );

                    onPostDeleted?.call();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao excluir post: $e')),
                    );
                  }
                }
              },
              itemBuilder: (context) {
                return [
                  if (post.publisherId == currentUserId) ...[
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir'),
                    ),
                  ],
                ];
              },
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 10, 12.0, 12.0),
            child: Text(
              post.content,
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
          ),

          if (post.images.isNotEmpty && post.images[0].isNotEmpty)
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
                      '$reactionCount',
                      style: TextStyle(color: displayColor, fontSize: 14),
                    ),
                    const SizedBox(width: 16),

                    IconButton(
                      icon : const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                      onPressed: onCommentButtonPressed,
                    ),
                    const SizedBox(width: 6),

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
        ],
      ),
    );
  }
}