import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/chatService/message_dto.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/chat_service.dart';

class ChatConversation extends StatefulWidget {
  final String profileId;
  final String profileName;
  final String profileImageUrl;

  const ChatConversation({
    Key? key,
    required this.profileId,
    required this.profileName,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  _ChatConversationState createState() => _ChatConversationState();
}

class _ChatConversationState extends State<ChatConversation> {
  List<MessageDto> _messages = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _canLoadMore = true;
  bool _isAtBottom = true;
  String? _userId;
  int _currentPage = 1;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeUserId();
    _loadMessages();
    _initializeWebSocket();

    ChatService.messageStream.listen((newMessage) {
      setState(() {
        _messages.add(newMessage);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isAtBottom && _scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        _isAtBottom = true;
      } else {
        _isAtBottom = false;
      }

      if (_scrollController.position.pixels <=
              _scrollController.position.minScrollExtent + 50 &&
          _canLoadMore) {
        _loadMoreMessages();
      }
    });
  }

  Future<void> _initializeUserId() async {
    try {
      final userId = await AuthenticationService.getProfileId();
      setState(() {
        _userId = userId;
      });
    } catch (e) {
      print('Erro ao obter o ID do usuário: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      List<MessageDto> messages = await ChatService.getMessagesAsync(
        widget.profileId,
        1,
      );
      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erro ao carregar mensagens: $e');
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    try {
      List<MessageDto> newMessages = await ChatService.getMessagesAsync(
        widget.profileId,
        _currentPage + 1,
      );

      if (newMessages.isNotEmpty) {
        setState(() {
          _currentPage++;
          _messages.insertAll(0, newMessages);
        });
      } else {
        setState(() {
          _canLoadMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      print('Erro ao carregar mais mensagens: $e');
    }
  }

  Future<void> _initializeWebSocket() async {
    try {
      await ChatService.initializeConnection(widget.profileId);
    } catch (e) {
      print('Erro ao inicializar conexão WebSocket: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    ChatService.stopConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.profileImageUrl)),
            const SizedBox(width: 8),
            Text(
              widget.profileName,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF191F2B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        _messages.sort(
                          (a, b) => a.timestamp!.compareTo(b.timestamp!),
                        );
                        final message = _messages[index];
                        final isCurrentUser =
                            _userId != null && message.senderId == _userId;
                        final bool showDateDivider =
                            index == 0 ||
                            DateFormat(
                                  'yyyy-MM-dd',
                                ).format(message.timestamp!) !=
                                DateFormat(
                                  'yyyy-MM-dd',
                                ).format(_messages[index - 1].timestamp!);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDateDivider)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        color: Colors.grey,
                                        thickness: 1,
                                        endIndent: 8,
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        "dd 'de' MMMM 'de' yyyy",
                                      ).format(message.timestamp!),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        color: Colors.grey,
                                        thickness: 1,
                                        indent: 8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Align(
                              alignment:
                                  isCurrentUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 8.0,
                                ),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color:
                                      isCurrentUser
                                          ? const Color(0xFF0fa0ce)
                                          : const Color(0xFF2a2f3c),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft:
                                        isCurrentUser
                                            ? const Radius.circular(12)
                                            : const Radius.circular(0),
                                    bottomRight:
                                        isCurrentUser
                                            ? const Radius.circular(0)
                                            : const Radius.circular(12),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.content ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat(
                                        'HH:mm',
                                      ).format(message.timestamp!),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          ),
          Divider(),
          Container(
            padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 16.0),
            color: const Color(0xFF191F2B),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) async {
                      await sendMessage(value);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF0fa0ce)),
                  onPressed: () async {
                    final messageText = _messageController.text;
                    await sendMessage(messageText);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF191F2B),
    );
  }

  Future<void> sendMessage(String value) async {
    if (value.trim().isNotEmpty) {
      await ChatService.sendMessageAsync(widget.profileId, value);

      // Rola para o final após enviar uma mensagem
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });

      _messageController.clear();
    }
  }
}
