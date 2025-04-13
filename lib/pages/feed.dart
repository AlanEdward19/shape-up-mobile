import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kDebugMode (já estava no seu DTO)
import 'package:shape_up_app/components/image_carousel_with_indicators.dart'; // Assumindo que você tem este componente
import 'package:shape_up_app/dtos/socialService/post_comment_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_reaction_dto.dart';
import 'package:shape_up_app/enums/socialService/reaction_type.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/social_service.dart';
import 'package:shape_up_app/widgets/socialService/comments/comments_modal.dart';

// --- Constantes ---
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

  // Story status (mantido como exemplo simples)
  final List<bool> _storyStatus = [
    false, true, true, false, false,
  ];

  @override
  void initState() {
    super.initState();
    _loadFeedData();
  }


  Future<void> _loadFeedData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final posts = await SocialService.getActivityFeedAsync();
      _posts = posts;

      Map<String, ReactionType?> userReactions = {};
      Map<String, String?> userComments = {};
      Map<String, List<PostReactionDto>> allReactions = {};

      final String currentUserId = await AuthenticationService.getProfileId();

      for (var post in posts) {
        try {
          final reactions = await SocialService.getPostReactionsAsync(post.id);
          allReactions[post.id] = reactions;

          if (reactions.isNotEmpty) {
            PostReactionDto? userReaction = reactions.firstWhere(
                  (r) => r.profileId == currentUserId);

            if(userReaction != null) {
              userReactions[post.id] = userReaction.reactionType;
            } else {
              userReactions[post.id] = null;
            }
          } else {
            userReactions[post.id] = null;
          }

          final comments = await SocialService.getPostCommentsAsync(post.id);
          _allPostComments[post.id] = comments;

          if(comments.isNotEmpty){
            PostCommentDto? userComment = comments.firstWhere(
                  (c) => c!.profileId == currentUserId);

            if(userComment != null) {
              userComments[post.id] = userComment.content;
            } else {
              userComments[post.id] = null;
            }
          }
          else {
            userComments[post.id] = null;
          }

        } catch (e) {
          // Erro ao carregar reações para UM post específico, não impede o resto
          if (kDebugMode) {
            print("Erro ao carregar reações para post ${post.id}: $e");
          }
          allReactions[post.id] = []; // Assume lista vazia em caso de erro
          userReactions[post.id] = null;
        }
      }

      setState(() {
        _currentUserReactions = userReactions;
        _allPostReactions = allReactions;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _error = "Erro ao carregar feed: $e";
        _isLoading = false;
      });
    }
  }

  // --- Lógica de Reação ---

  // Função chamada quando um emoji é selecionado no popup
  Future<void> _handleReactionSelected(String postId, ReactionType selectedReaction) async {
    final currentReaction = _currentUserReactions[postId];
    final originalReactions = List<PostReactionDto>.from(_allPostReactions[postId] ?? []);
    final String currentUserId = await AuthenticationService.getProfileId();

    // 1. Atualização Otimista da UI
    setState(() {
      if (currentReaction == selectedReaction) {
        // Clicou na mesma reação -> Remover
        _currentUserReactions[postId] = null;
        _allPostReactions[postId]?.removeWhere((r) => r.profileId == currentUserId);
      } else {
        // Nova reação ou mudou de reação
        _currentUserReactions[postId] = selectedReaction;
        // Remove a antiga se existia (simulação sem ID)
        if(currentReaction != null) {
          _allPostReactions[postId]?.removeWhere((r) => /*r.profileId == currentUserId &&*/ r.reactionType == currentReaction);
        }
        // Adiciona a nova (simulação sem ID - adiciona um DTO fake)
        // O ideal é ter o ID do usuário e criar um DTO real
        _allPostReactions[postId]?.add(PostReactionDto(
            "CURRENT_USER_ID_PLACEHOLDER",
            DateTime.now().toIso8601String(),
            selectedReaction,
            postId,
            "temp_id_${DateTime.now().millisecondsSinceEpoch}" // ID temporário
        ));
      }
    });

    // 2. Chamada à API
    try {
      if (currentReaction == selectedReaction) {
        // Remover reação
        await SocialService.deleteReactionAsync(postId);
      } else if (currentReaction != null) {
        // Mudar reação (delete + add)
        await SocialService.deleteReactionAsync(postId);
        await SocialService.reactToPostAsync(postId, selectedReaction);
      } else {
        // Adicionar nova reação
        await SocialService.reactToPostAsync(postId, selectedReaction);
      }

      final updatedReactions = await SocialService.getPostReactionsAsync(postId);
      setState(() {
        _allPostReactions[postId] = updatedReactions;
        // Atualiza a reação do usuário novamente com base nos dados reais
        // _currentUserReactions[postId] = updatedReactions.firstWhere((r) => r.profileId == currentUserId, orElse: () => null)?.reactionType; // Precisa do ID real
        // --- Simulação SEM ID do usuário ---
        if (updatedReactions.isNotEmpty) {
          final userReaction = updatedReactions.firstWhere(
                  (r) => r.reactionType == selectedReaction, // Prioriza a que acabou de ser selecionada
              orElse: () => updatedReactions.first
          );
          // Assumimos que esta é a do usuário logado
          _currentUserReactions[postId] = userReaction.reactionType;
        } else {
          _currentUserReactions[postId] = null;
        }
        // --- Fim Simulação ---
      });

    } catch (e) {
      // 4. Reverter em caso de erro e mostrar mensagem
      setState(() {
        _currentUserReactions[postId] = currentReaction; // Reverte a reação do usuário
        _allPostReactions[postId] = originalReactions; // Reverte a lista/contagem
      });
      if (mounted) { // Verifica se o widget ainda está na árvore
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reagir: ${e.toString().replaceFirst("Exception: ", "")}')),
        );
      }
      if (kDebugMode) {
        print("Erro ao atualizar reação para post $postId: $e");
      }
    }
  }


  // Mostra o popup de seleção de reações
  void _showReactionPopup(BuildContext context, String postId) {
    final RenderBox buttonBox = context.findRenderObject() as RenderBox;
    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonBox.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return Stack(
          children: [
            Positioned(
              left: buttonPosition.dx + buttonSize.width / 2 - 30,
              top: buttonPosition.dy + buttonSize.height - 100,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: reactionEmojiMap.values.map((emoji) {
                        return GestureDetector(
                          onTap: () {
                            final reactionType = ReactionPopup._emojiToReactionType[emoji];
                            if (reactionType != null) {
                              Navigator.of(dialogContext).pop();
                              _handleReactionSelected(postId, reactionType);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
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
            onPressed: () { /* TODO: Implement notifications logic */ },
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white),
            onPressed: () { /* TODO: Implement messages logic */ },
          ),
        ],
      ),
      body: _buildBody(),
      // bottomNavigationBar: BottomNavBar(), // Se você tiver uma barra de navegação
    );
  }

  // --- Construção da UI ---
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    } else if (_error != null) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Erro: $_error', style: const TextStyle(color: Colors.redAccent)),
          ));
    } else if (_posts.isEmpty) {
      return const Center(child: Text('Nenhum post encontrado.', style: TextStyle(color: Colors.white)));
    } else {
      return RefreshIndicator( // Adiciona Pull-to-Refresh
        onRefresh: _loadFeedData,
        color: Colors.white,
        backgroundColor: kBackgroundColor,
        child: ListView.builder(
          itemCount: _posts.length + 1, // +1 para a seção de stories
          itemBuilder: (context, index) {
            if (index == 0) {
              // --- Seção de Stories ---
              return StorySection(storyStatus: _storyStatus);
            } else {
              // --- Card do Post ---
              final postIndex = index - 1;
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
                onReactionSelected: (postId, reactionType) {
                  _handleReactionSelected(postId, reactionType);
                },
                buildReactionIcons: (postId) => _buildReactionIcons(postId),
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
      // Caso não haja reações, exibe o ícone padrão de "like"
      return Text(
        kDefaultReactionEmoji,
        style: const TextStyle(fontSize: 22),
      );
    }

    // Conta as reações por tipo
    final reactionCounts = <ReactionType, int>{};
    for (var reaction in reactions) {
      reactionCounts[reaction.reactionType] =
          (reactionCounts[reaction.reactionType] ?? 0) + 1;
    }

    // Ordena as reações pela quantidade (decrescente)
    final sortedReactions = reactionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topReactions = sortedReactions.take(3);

    // Gera os emojis ordenados
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: topReactions.map((entry) {
          final emoji = reactionEmojiMap[entry.key] ?? kDefaultReactionEmoji;
          return Padding(
            padding: const EdgeInsets.only(right: 4.0), // Ajuste no espaçamento
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// --- Story Section Widget --- (Sem alterações significativas)
class StorySection extends StatelessWidget {
  final List<bool> storyStatus;
  const StorySection({required this.storyStatus, super.key});

  @override
  Widget build(BuildContext context) {
    final storyLabels = ['Seu Story', 'Perfil 1', 'Perfil 2', 'Perfil 3', 'Perfil 4'];
    return Container(
      height: 120,
      color: kBackgroundColor,
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

// --- Story Avatar Widget --- (Sem alterações significativas)
class StoryAvatar extends StatelessWidget {
  final String label;
  final bool isNotSeen;
  const StoryAvatar({required this.label, required this.isNotSeen, super.key});

  @override
  Widget build(BuildContext context) {
    final Gradient seenGradient = LinearGradient(
      colors: [Colors.grey.shade600, Colors.grey.shade800],
      begin: Alignment.topRight, end: Alignment.bottomLeft,
    );
    final Gradient notSeenGradient = const LinearGradient(
      colors: [Colors.pinkAccent, Colors.blueAccent],
      begin: Alignment.topRight, end: Alignment.bottomLeft,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: kStoryAvatarSize, height: kStoryAvatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isNotSeen ? notSeenGradient : seenGradient,
                ),
              ),
              const CircleAvatar(
                radius: kStoryAvatarRadius,
                backgroundColor: Colors.grey,
                // backgroundImage: NetworkImage('URL_DA_IMAGEM_AQUI'), // Adicione a imagem real aqui
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white),
            overflow: TextOverflow.ellipsis, maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// --- Post Card Widget --- (Modificado para aceitar e exibir estado da reação)
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
    // Determina o emoji e a cor a serem exibidos com base na reação atual
    final String displayEmoji;
    final Color displayColor;

    if (currentUserReaction != null) {
      displayEmoji = reactionEmojiMap[currentUserReaction] ?? kDefaultReactionEmoji; // Usa o emoji mapeado ou padrão
      displayColor = Colors.blue; // Ou outra cor para indicar que *há* uma reação
    } else {
      displayEmoji = kDefaultReactionEmoji; // Emoji de 'like' padrão
      displayColor = Colors.grey; // Cor cinza para indicar ausência de reação do usuário
    }


    return Card(
      margin: kCardMargin,
      color: kBackgroundColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Cabeçalho do Post ---
          ListTile(
            leading: CircleAvatar(
              backgroundColor: kPlaceholderColor, // Cor de fundo enquanto carrega
              backgroundImage: NetworkImage(post.publisherImageUrl),
              onBackgroundImageError: (exception, stackTrace) {
                // Opcional: Logar erro ou mostrar inicial
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

          // --- Imagem/Carrossel do Post ---
          if (post.images.isNotEmpty) // Só mostra o container se houver imagens
            SizedBox(
              height: kPostImageHeight, // Use constant
              child: ImageCarouselWithIndicator(imageUrls: post.images),
            )
          else
            const SizedBox(height: 10), // Espaço se não houver imagem

          // --- Barra de Ações (Reações, Comentários, Shares) ---
          Padding(
            padding: kDefaultPadding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ações da Esquerda (Reação, Contagem, Comentários)
                Row(
                  children: [
                    // Botão de Reação (Usa um Builder para obter o contexto específico do botão)
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

                    // Quantidade de Reações
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

                // Ações da Direita (Compartilhar - TODO: Adicionar contagem real)
                Row(
                  children: [
                    const Icon(
                      Icons.send_outlined, // Ou Icons.share
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '0', // Placeholder - TODO: Obter contagem de compartilhamentos
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),

              ],
            ),
          ),

          // --- Descrição/Conteúdo do Post ---
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0), // Ajustado padding top
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


// --- Reaction Popup Widget --- (Modificado para retornar ReactionType)
class ReactionPopup extends StatelessWidget {
  final Function(ReactionType) onEmojiSelected; // Retorna o Enum

  const ReactionPopup({required this.onEmojiSelected, super.key});

  // Mapeamento inverso de Emoji para ReactionType
  static final Map<String, ReactionType> _emojiToReactionType = {
    for (var entry in reactionEmojiMap.entries) entry.value : entry.key
  };

  @override
  Widget build(BuildContext context) {
    // Pega apenas os emojis que temos no mapeamento (garante consistência)
    final List<String> reactionEmojis = reactionEmojiMap.values.toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // Ajuste no padding
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98), // Quase opaco
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center, // Centraliza os emojis
        children: reactionEmojis.map((emoji) {
          // Adiciona espaçamento entre os emojis
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0), // Espaçamento
            child: InkWell( // Usar InkWell para feedback visual
              onTap: () {
                final reactionType = _emojiToReactionType[emoji];
                if (reactionType != null) {
                  onEmojiSelected(reactionType); // Chama o callback com o Enum
                } else {
                  if (kDebugMode) print("Erro: Emoji '$emoji' não mapeado para ReactionType.");
                }
              },
              borderRadius: BorderRadius.circular(20), // Raio para o InkWell
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}