import 'package:flutter/material.dart';
import 'package:shape_up_app/services/chat_service.dart';
import 'package:shape_up_app/dtos/chatService/message_dto.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<MessageDto> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentMessages();
  }

  Future<void> _loadRecentMessages() async {
    try {
      List<MessageDto> messages = await ChatService.getRecentMessagesAsync();
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erro ao carregar mensagens: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF191F2B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _messages.isEmpty
          ? const Center(
        child: Text(
          "Nenhuma mensagem recente.",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return ListTile(
            title: Text(
              message.content ?? '',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Enviado por: ${message.senderId}',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFF191F2B),
    );
  }
}