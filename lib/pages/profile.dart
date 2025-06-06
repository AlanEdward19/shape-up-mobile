import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shape_up_app/components/personalized_circle_avatar.dart';
import 'package:shape_up_app/dtos/socialService/post_comment_dto.dart';
import 'package:shape_up_app/dtos/socialService/profile_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_dto.dart';
import 'package:shape_up_app/dtos/socialService/friend_request_dto.dart';
import 'package:shape_up_app/enums/socialService/friend_request_status.dart';
import 'package:shape_up_app/enums/socialService/gender.dart';
import 'package:shape_up_app/pages/chat_conversation.dart';
import 'package:shape_up_app/pages/profile_post.dart';
import 'package:shape_up_app/pages/settings.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/social_service.dart';

class Profile extends StatefulWidget {
  final String profileId;

  const Profile({required this.profileId, super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  late Future<ProfileDto> _profileFuture;
  late Future<List<PostDto>> _postsFuture;
  late Future<String> _loggedInProfileId;
  List<FriendRequestDto> _friendRequests = [];

  @override
  void initState() {
    super.initState();
    _profileFuture = SocialService.viewProfileAsync(widget.profileId);
    _postsFuture = SocialService.getPostsByProfileIdAsync(widget.profileId);
    _loggedInProfileId = AuthenticationService.getProfileId();
    _loadFriendRequests();
  }

  Future<void> _loadFriendRequests() async {
    try {
      final requests = await SocialService.getFriendRequestsAsync();
      setState(() {
        _friendRequests = requests;
      });
    } catch (e) {
      print("Erro ao carregar solicitações de amizade: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF191F2B),
        actions: [
          FutureBuilder<String>(
            future: _loggedInProfileId,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              } else if (snapshot.hasData &&
                  snapshot.data == widget.profileId) {
                return IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                const Settings(),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    ).then((_) {
                      setState(() {
                        _profileFuture = SocialService.viewProfileAsync(widget.profileId);
                        _postsFuture = SocialService.getPostsByProfileIdAsync(widget.profileId);
                        _loadFriendRequests();
                      });
                    });
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<ProfileDto>(
        future: _profileFuture,
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (profileSnapshot.hasError) {
            return Center(child: Text("Erro: ${profileSnapshot.error}"));
          } else if (profileSnapshot.hasData) {
            final profile = profileSnapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        personalizedCircleAvatar(
                          profile.imageUrl,
                          "${profile.firstName} ${profile.lastName}",
                          40,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${profile.firstName} ${profile.lastName}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStat("Publicações", profile.posts),
                                  _buildStat("Seguidores", profile.followers),
                                  _buildStat("Seguindo", profile.following),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if(profile.bio.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            profile.bio,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16)
                      ],
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              "${profile.country}, ${profile.city} - ${profile.state}",
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),

                        if (profile.gender != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                genderToString[profile.gender]!,
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ],

                        if (profile.birthDate.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.cake, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat("dd/MM").format(DateTime.parse(profile.birthDate)),
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _loggedInProfileId,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      } else if (snapshot.hasData &&
                          snapshot.data != profile.id) {
                        final friendRequest = _friendRequests.firstWhere(
                          (request) => request.profileId == profile.id,
                          orElse:
                              () => FriendRequestDto(
                                '',
                                FriendRequestStatus.Pending,
                                null,
                              ),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildMessageButton(profile),
                                  const SizedBox(width: 5),
                                  _buildFollowButton(profile),
                                  const SizedBox(width: 5),
                                  if (profile.isFriend) _buildUnfriendButton(profile),
                                  if (!profile.isFriend && friendRequest.profileId != '' && friendRequest.status == FriendRequestStatus.Pending)
                                    _buildCancelRequestButton(friendRequest),
                                  if (!profile.isFriend && friendRequest.profileId == '' && friendRequest.status != FriendRequestStatus.PendingResponse)
                                    _buildSendRequestButton(friendRequest),
                                ],
                              ),
                              const SizedBox(height: 15),
                              if (friendRequest.profileId != '' && friendRequest.status == FriendRequestStatus.PendingResponse)
                                _buildPendingRequestActions(profile),
                            ],
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                  const Divider(),
                  FutureBuilder<List<PostDto>>(
                    future: _postsFuture,
                    builder: (context, postsSnapshot) {
                      if (postsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (postsSnapshot.hasError) {
                        return Center(
                          child: Text("Erro: ${postsSnapshot.error}"),
                        );
                      } else if (postsSnapshot.hasData) {
                        final posts = postsSnapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ProfilePost(
                                        posts: posts,
                                        initialIndex: index,
                                      ),
                                    ),
                                  );
                                },
                                child: posts[index].images.isNotEmpty
                                    ? Image.network(
                                  posts[index].images[0],
                                  fit: BoxFit.cover,
                                )
                                    : const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 45,
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text("Nenhum post disponível", style: TextStyle(color: Colors.white)),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text("Nenhum dado disponível"));
          }
        },
      ),
    );
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          "$count",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMessageButton(ProfileDto profile) {
    return Expanded(
      child: ElevatedButton(
        onPressed: profile.isFriend
            ? () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatConversation(
                profileId: profile.id,
                profileName: "${profile.firstName} ${profile.lastName}",
                profileImageUrl: profile.imageUrl,
              ),
            ),
          );
        }
            : () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Atenção"),
                content: const Text(
                  "Para enviar mensagem a esse perfil é necessário enviar uma solicitação de amizade e ser aceita primeiro.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: profile.isFriend ? Colors.blue : Colors.grey,
        ),
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildFollowButton(ProfileDto profile) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          try {
            if (profile.isFollowing) {
              await SocialService.unfollowUser(profile.id);
            } else {
              await SocialService.followUser(profile.id);
            }
            setState(() {
              _profileFuture = SocialService.viewProfileAsync(widget.profileId);
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro: $e")),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: profile.isFollowing ? Colors.red : Colors.blue,
        ),
        child: Icon(
          profile.isFollowing ? Icons.person_remove : Icons.person_add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUnfriendButton(ProfileDto profile) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          try {
            await SocialService.deleteFriendAsync(profile.id);
            setState(() {
              _profileFuture = SocialService.viewProfileAsync(widget.profileId);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Amizade desfeita com sucesso!")),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro: $e")),
            );
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Icon(Icons.group_remove, color: Colors.white),
      ),
    );
  }

  Widget _buildCancelRequestButton(FriendRequestDto friendRequest) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          await SocialService.removeFriendRequestAsync(friendRequest.profileId);
          _loadFriendRequests();
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Icon(Icons.cancel, color: Colors.white),
      ),
    );
  }

  Widget _buildSendRequestButton(FriendRequestDto friendRequest) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () async {
          try {
            await SocialService.sendFriendRequestAsync(friendRequest.profileId, null);
            setState(() {
              _friendRequests.add(
                FriendRequestDto(
                  friendRequest.profileId,
                  FriendRequestStatus.Pending,
                  null,
                ),
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Solicitação de amizade enviada!")),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erro: $e")),
            );
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        child: const Icon(Icons.group_add, color: Colors.white),
      ),
    );
  }

  Widget _buildPendingRequestActions(ProfileDto profile) {
    return Column(
      children: [
        const Text(
          "Você possui uma solicitação de amizade pendente desse perfil",
          style: TextStyle(color: Colors.white), textAlign: TextAlign.center,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await SocialService.manageFriendRequestAsync(profile.id, true);
                setState(() {
                  _profileFuture = SocialService.viewProfileAsync(widget.profileId);
                  _loadFriendRequests();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Aceitar", style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(width: 8, height: 10),

            ElevatedButton(
              onPressed: () async {
                await SocialService.manageFriendRequestAsync(profile.id, false);
                setState(() {
                  _profileFuture = SocialService.viewProfileAsync(widget.profileId);
                  _loadFriendRequests();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Recusar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}
