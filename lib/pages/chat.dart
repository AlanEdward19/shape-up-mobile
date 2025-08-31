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
  List<Map<String, dynamic>> _personalMessagesWithProfiles = [];
  List<Map<String, dynamic>> _professionalMessagesWithProfiles = [];
  List<Map<String, dynamic>> _filteredPersonalMessagesWithProfiles = [];
  List<Map<String, dynamic>> _filteredProfessionalMessagesWithProfiles = [];
  bool _isLoading = true;
  bool _isProfessionalChat = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterMessages);
    _loadRecentMessages(false); // Default to "Pessoal"
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentMessages(bool isProfessionalChat) async {
    try {
      final userId = await AuthenticationService.getProfileId();
      List<MessageDto> messages = await ChatService.getRecentMessagesAsync(isProfessionalChat);

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
        if (isProfessionalChat) {
          _professionalMessagesWithProfiles = messagesWithProfiles;
          _filteredProfessionalMessagesWithProfiles = messagesWithProfiles;
        } else {
          _personalMessagesWithProfiles = messagesWithProfiles;
          _filteredPersonalMessagesWithProfiles = messagesWithProfiles;
        }
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
        if(_isProfessionalChat) {
          _filteredProfessionalMessagesWithProfiles = _professionalMessagesWithProfiles;
        } else {
          _filteredPersonalMessagesWithProfiles = _personalMessagesWithProfiles;
        }
      });
      return;
    }

    setState(() {
      if(_isProfessionalChat)
        {
          _filteredProfessionalMessagesWithProfiles = _professionalMessagesWithProfiles.where((item) {
            final profile = item['profile'] as SimplifiedProfileDto;
            final fullName = '${profile.firstName} ${profile.lastName}'.toLowerCase();
            return fullName.split(' ').any((namePart) =>
            StringSimilarity.compareTwoStrings(namePart.toLowerCase(), query.toLowerCase()) > 0.6 ||
                profile.firstName.toLowerCase().contains(query.toLowerCase()) ||
                profile.lastName.toLowerCase().contains(query.toLowerCase()));
          }).toList();
        }
      else{
        _filteredPersonalMessagesWithProfiles = _personalMessagesWithProfiles.where((item) {
          final profile = item['profile'] as SimplifiedProfileDto;
          final fullName = '${profile.firstName} ${profile.lastName}'.toLowerCase();
          return fullName.split(' ').any((namePart) =>
          StringSimilarity.compareTwoStrings(namePart.toLowerCase(), query.toLowerCase()) > 0.6 ||
              profile.firstName.toLowerCase().contains(query.toLowerCase()) ||
              profile.lastName.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversas', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF101827),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.white,
            onTap: (index) {
              setState(() {
                _isProfessionalChat = index == 1; // true for "Profissional", false for "Pessoal"
              });
              _loadRecentMessages(_isProfessionalChat);
            },
            tabs: const [
              Tab(text: 'Pessoal'),
              Tab(text: 'Profissional'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChatList(false), // Pessoal
            _buildChatList(true),  // Profissional
          ],
        ),
        backgroundColor: const Color(0xFF101827),
      ),
    );
  }

  Widget _buildChatList(bool isProfessionalChat) {
    final messages = isProfessionalChat
        ? _filteredProfessionalMessagesWithProfiles
        : _filteredPersonalMessagesWithProfiles;

    return Column(
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
              ? const Center(child: CircularProgressIndicator(color: Colors.blue,))
              : messages.isEmpty
              ? const Center(
            child: Text(
              "Nenhuma mensagem recente.",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )
              : ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index]['message'] as MessageDto;
              final profile = messages[index]['profile'] as SimplifiedProfileDto;

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
                        isProfessionalChat: isProfessionalChat,
                      ),
                    ),
                  );

                  _loadRecentMessages(isProfessionalChat);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}