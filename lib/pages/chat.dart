import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/socialService/simplified_profile_dto.dart';
import 'package:shape_up_app/pages/chat_conversation.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/chat_service.dart';
import 'package:shape_up_app/dtos/chatService/message_dto.dart';
import 'package:shape_up_app/services/social_service.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Map<String, dynamic>> _messagesWithProfiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentMessages();
  }

  Future<void> _loadRecentMessages() async {
    try {
      final userId = await AuthenticationService.getProfileId();
      List<MessageDto> messages = await ChatService.getRecentMessagesAsync();

      List<Map<String, dynamic>> messagesWithProfiles = [];
      for (var message in messages) {
        final otherUserId = message.senderId == userId ? message.receiverId : message.senderId;
        if (otherUserId != null) {
          final profile = await SocialService.viewProfileSimplifiedAsync(otherUserId);
          messagesWithProfiles.add({
            'message': message,
            'profile': profile,
          });
        }
      }

      setState(() {
        _messagesWithProfiles = messagesWithProfiles;
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
        title: Text('Conversas', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF191F2B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _messagesWithProfiles.isEmpty
          ? const Center(
        child: Text(
          "Nenhuma mensagem recente.",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: _messagesWithProfiles.length,
        itemBuilder: (context, index) {
          final message = _messagesWithProfiles[index]['message'] as MessageDto;
          final profile = _messagesWithProfiles[index]['profile'] as SimplifiedProfileDto;

          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(profile.imageUrl),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${profile.firstName} ${profile.lastName}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  '${message.timestamp?.hour.toString().padLeft(2, '0')}:${message.timestamp?.minute.toString().padLeft(2, '0')} - ${message.timestamp?.day.toString().padLeft(2, '0')}/${message.timestamp?.month.toString().padLeft(2, '0')}/${message.timestamp?.year}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            subtitle: Text(
              message.content ?? '',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatConversation(
                    profileId: profile.id,
                    profileName: '${profile.firstName} ${profile.lastName}',
                    profileImageUrl: profile.imageUrl,
                  ),
                ),
              );

              _loadRecentMessages();
            },
          );
        },
      ),
      backgroundColor: const Color(0xFF191F2B),
    );
  }
}