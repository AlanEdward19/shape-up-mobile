import 'package:flutter/material.dart';
import 'package:shape_up_app/components/personalized_circle_avatar.dart';
import 'package:shape_up_app/dtos/socialService/simplified_profile_dto.dart';
import 'package:shape_up_app/pages/chat_conversation.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/chat_service.dart';
import 'package:shape_up_app/dtos/chatService/message_dto.dart';
import 'package:shape_up_app/services/social_service.dart';
import 'package:string_similarity/string_similarity.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Map<String, dynamic>> _messagesWithProfiles = [];
  List<Map<String, dynamic>> _filteredMessagesWithProfiles = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecentMessages();
    _searchController.addListener(_filterMessages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        _filteredMessagesWithProfiles = messagesWithProfiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erro ao carregar mensagens: $e');
    }
  }

  void _filterMessages() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredMessagesWithProfiles = _messagesWithProfiles;
      });
      return;
    }

    setState(() {
      _filteredMessagesWithProfiles = _messagesWithProfiles.where((item) {
        final profile = item['profile'] as SimplifiedProfileDto;
        final fullName = '${profile.firstName} ${profile.lastName}'.toLowerCase();
        return fullName.split(' ').any((namePart) =>
        StringSimilarity.compareTwoStrings(namePart.toLowerCase(), query.toLowerCase()) > 0.6 ||
            profile.firstName.toLowerCase().contains(query.toLowerCase()) ||
            profile.lastName.toLowerCase().contains(query.toLowerCase()));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversas', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF191F2B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Procurar contato...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2A2F3C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMessagesWithProfiles.isEmpty
                ? const Center(
              child: Text(
                "Nenhuma mensagem recente.",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
                : ListView.builder(
              itemCount: _filteredMessagesWithProfiles.length,
              itemBuilder: (context, index) {
                final message = _filteredMessagesWithProfiles[index]['message'] as MessageDto;
                final profile = _filteredMessagesWithProfiles[index]['profile'] as SimplifiedProfileDto;

                return ListTile(
                  leading: personalizedCircleAvatar(profile.imageUrl, '${profile.firstName} ${profile.lastName}', 25),
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
          ),
        ],
      ),
      backgroundColor: const Color(0xFF191F2B),
    );
  }
}