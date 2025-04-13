import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/socialService/profile_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_dto.dart';
import 'package:shape_up_app/services/social_service.dart';

class Profile extends StatefulWidget {
  final String profileId;

  const Profile({required this.profileId, Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  late Future<ProfileDto> _profileFuture;
  late Future<List<PostDto>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = SocialService.viewProfileAsync(widget.profileId);
    _postsFuture = SocialService.getPostsByProfileIdAsync(widget.profileId);
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF191F2B),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navegar para a página de configurações
            },
          ),
        ],
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
                  // Cabeçalho do Perfil
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto do perfil
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(profile.imageUrl),
                        ),
                        const SizedBox(width: 16),
                        // Informações do perfil
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${profile.firstName} ${profile.lastName}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                  // Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      profile.bio,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Localização
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "${profile.country}, ${profile.city} - ${profile.state}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const Divider(),
                  // Lista de Posts
                  FutureBuilder<List<PostDto>>(
                    future: _postsFuture,
                    builder: (context, postsSnapshot) {
                      if (postsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (postsSnapshot.hasError) {
                        return Center(child: Text("Erro: ${postsSnapshot.error}"));
                      } else if (postsSnapshot.hasData) {
                        final posts = postsSnapshot.data!;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                            ),
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                posts[index].images.isNotEmpty ? posts[index].images[0] : "",
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        );
                      } else {
                        return const Center(child: Text("Nenhum post disponível"));
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}