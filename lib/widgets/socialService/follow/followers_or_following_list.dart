import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/socialService/follow_user_dto.dart';
import 'package:shape_up_app/pages/profile.dart';
import 'package:shape_up_app/services/social_service.dart';

class FollowersOrFollowingList extends StatefulWidget {
  final String profileId;
  final bool isFollowers;

  const FollowersOrFollowingList({
    required this.profileId,
    required this.isFollowers,
    Key? key,
  }) : super(key: key);

  @override
  _FollowersOrFollowingListState createState() => _FollowersOrFollowingListState();
}

class _FollowersOrFollowingListState extends State<FollowersOrFollowingList> {
  final List<FollowUserDto> _users = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading && _hasMore) {
        _loadUsers();
      }
    });
  }

  Future<void> _loadUsers() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newUsers = widget.isFollowers
          ? await SocialService.getFollowersAsync(widget.profileId, _currentPage, 10)
          : await SocialService.getFollowingAsync(widget.profileId, _currentPage, 10);

      setState(() {
        _users.addAll(newUsers);
        _currentPage++;
        _hasMore = newUsers.isNotEmpty; // Atualiza _hasMore corretamente
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar usuários: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          AppBar(
            backgroundColor: const Color(0xFF101827),
            title: Text(widget.isFollowers ? "Seguidores" : "Seguindo", style: TextStyle(color: Colors.white),),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _users.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _users.length) {
                    final user = _users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user.imageUrl),
                      ),
                      title: Text(
                        "${user.firstName} ${user.lastName}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Profile(profileId: user.profileId),
                          ),
                        );
                      },
                    );
                  } else if (_isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: Colors.blue,),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink(); // Não exibe nada se não estiver carregando
                  }
                }
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}