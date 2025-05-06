import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/socialService/post_comment_dto.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/social_service.dart';
import 'comment_input.dart';
import 'comment_list.dart';

void showCommentsModal(BuildContext context, String postId, List<PostCommentDto> comments) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black87,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return CommentsModal(postId: postId, comments: comments);
    },
  );
}

class CommentsModal extends StatefulWidget {
  final String postId;
  final List<PostCommentDto> comments;

  const CommentsModal({required this.postId, required this.comments,super.key});

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;
  List<PostCommentDto> _comments = [];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _comments = widget.comments;
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    try {
      final userId = await AuthenticationService.getProfileId();
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      if (kDebugMode) print("Erro ao carregar ID do usuário: $e");
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await SocialService.getPostCommentsAsync(widget.postId);
      final userId = await AuthenticationService.getProfileId();
      setState(() {
        _comments = comments;
        _currentUserId = userId;
      });
    } catch (e) {
      if (kDebugMode) print("Erro ao carregar comentários: $e");
    }
  }

  Future<void> _sendComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    try {
      await SocialService.commentOnPostAsync(widget.postId, _commentController.text.trim());
      _commentController.clear();
      await _loadComments();
    } catch (e) {
      if (kDebugMode) print("Erro ao enviar comentário: $e");
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await SocialService.deleteCommentAsync(commentId);
      await _loadComments();
    } catch (e) {
      if (kDebugMode) print("Erro ao excluir comentário: $e");
    }
  }

  Future<void> _editComment(String commentId, String currentContent) async {
    final TextEditingController editController = TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Editar Comentário"),
          content: TextField(
            controller: editController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: "Digite o novo comentário"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await SocialService.editPostCommentAsync(commentId, editController.text.trim());
                  Navigator.of(context).pop();
                  await _loadComments();
                } catch (e) {
                  if (kDebugMode) print("Erro ao editar comentário: $e");
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Comentários",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Expanded(
            child: CommentList(
              comments: _comments,
              currentUserId: _currentUserId,
              onDelete: _deleteComment,
              onEdit: _editComment,
            ),
          ),
          CommentInput(
            controller: _commentController,
            isSending: _isSending,
            onSend: _sendComment,
          ),
        ],
      ),
    );
  }
}
