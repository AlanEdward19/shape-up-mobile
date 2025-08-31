import 'package:flutter/material.dart';
import 'package:shape_up_app/components/personalized_circle_avatar.dart';
import 'package:shape_up_app/dtos/socialService/friend_dto.dart';
import 'package:shape_up_app/dtos/socialService/friend_recommendation_dto.dart';
import 'package:shape_up_app/pages/profile.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/social_service.dart';

class Friends extends StatefulWidget {
  const Friends({super.key});

  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final List<FriendDto> _friends = [];
  final List<FriendRecommendationDto> _friendRecommendations = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _loadFriendRecommendations();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final profileId = await AuthenticationService.getProfileId();
      final newFriends = await SocialService.getFriendsAsync(profileId, _currentPage, 100);

      setState(() {
        _friends.addAll(newFriends);
        _hasMore = newFriends.isNotEmpty;
        if (_hasMore) _currentPage++;
      });
    } catch (e) {
      print("Erro ao carregar amigos: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFriendRecommendations() async {
    try {
      final recommendations = await SocialService.getFriendRecommendationsAsync();
      setState(() {
        _friendRecommendations.addAll(recommendations);
      });
    } catch (e) {
      print("Erro ao carregar recomendações de amizade: $e");
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent &&
        !_isLoading &&
        _hasMore) {
      _loadFriends();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amigos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF101827),
      ),
      body: ListView(
        controller: _scrollController,
        children: [
          // Lista de amigos
          if (_friends.isEmpty && !_isLoading)
            const Center(
              child: Text(
                "Nenhum amigo encontrado.",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          else
            ..._friends.map((friend) => ListTile(
              leading: personalizedCircleAvatar(friend.imageUrl, "${friend.firstName} ${friend.lastName}", 20),
              title: Text(
                "${friend.firstName} ${friend.lastName}",
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Profile(profileId: friend.profileId),
                  ),
                );
              },
            )),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: Colors.blue,),
              ),
            ),
          const SizedBox(height: 16),
          // Seção "Talvez você conheça"
          if (_friendRecommendations.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Talvez você conheça",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ..._friendRecommendations.map((recommendation) => ListTile(
                  leading: personalizedCircleAvatar(recommendation.Profile.imageUrl, "${recommendation.Profile.firstName} ${recommendation.Profile.lastName}", 20),
                  title: Text(
                    "${recommendation.Profile.firstName} ${recommendation.Profile.lastName}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "${recommendation.MutualFriends} amigos em comum",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Profile(profileId: recommendation.Profile.id),
                      ),
                    );
                  },
                )),
              ],
            ),
        ],
      ),
      backgroundColor: const Color(0xFF101827),
    );
  }
}