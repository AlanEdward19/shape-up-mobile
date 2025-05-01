import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/socialService/friend_dto.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadFriends();
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
        backgroundColor: const Color(0xFF191F2B),
      ),
      body: _friends.isEmpty && !_isLoading
          ? const Center(
        child: Text(
          "Nenhum amigo encontrado.",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      )
          : ListView.builder(
        controller: _scrollController,
        itemCount: _friends.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _friends.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final friend = _friends[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(friend.imageUrl),
            ),
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
          );
        },
      ),
      backgroundColor: const Color(0xFF191F2B),
    );
  }
}