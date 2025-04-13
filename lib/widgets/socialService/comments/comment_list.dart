import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/socialService/post_comment_dto.dart';

class CommentList extends StatelessWidget {
  final List<PostCommentDto> comments;
  final String? currentUserId;
  final Function(String id) onDelete;
  final Function(String id, String content) onEdit;

  const CommentList({
    required this.comments,
    required this.currentUserId,
    required this.onDelete,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Center(
        child: Text(
          "Nenhum comentário ainda.",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final isCurrentUser = comment.profileId == currentUserId;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(comment.profileImageUrl),
            onBackgroundImageError: (_, __) {
              Text(
                  comment.profileFirstName[0],
                  style: const TextStyle(color: Colors.white)
              );
            },
          ),
          title: Text(
            "${comment.profileFirstName} ${comment.profileLastName}",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            comment.content,
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: isCurrentUser
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => onEdit(comment.id, comment.content),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => onDelete(comment.id),
              ),
            ],
          )
              : null,
        );
      },
    );
  }
}
