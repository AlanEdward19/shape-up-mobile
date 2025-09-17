import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shape_up_app/dtos/socialService/follow_user_dto.dart';
import 'package:shape_up_app/dtos/socialService/friend_dto.dart';
import 'package:shape_up_app/dtos/socialService/friend_recommendation_dto.dart';
import 'package:shape_up_app/dtos/socialService/friend_request_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_comment_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_reaction_dto.dart';
import 'package:shape_up_app/dtos/socialService/profile_dto.dart';
import 'package:shape_up_app/dtos/socialService/simplified_profile_dto.dart';
import 'package:shape_up_app/enums/socialService/gender.dart';
import 'package:shape_up_app/enums/socialService/reaction_type.dart';
import 'package:shape_up_app/enums/socialService/post_visibility.dart';
import 'package:shape_up_app/services/authentication_service.dart';

class SocialService {
  static final String baseUrl = dotenv.env['SOCIAL_SERVICE_BASE_URL']!;

  static Map<String, String> createHeaders(String token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    return headers;
  }

  static Future<ProfileDto> viewProfileAsync(String id) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Profile/ViewProfile/$id'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProfileDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erro ao carregar perfil");
    }
  }

  static Future<SimplifiedProfileDto> viewProfileSimplifiedAsync(String id) async{
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Profile/ViewProfile/$id/simplified'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      return SimplifiedProfileDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erro ao carregar perfil");
    }
  }

  static Future<void> editProfileAsync(
    Gender? gender,
    String? birthDate,
    String? bio,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/v1/Profile/EditProfile'),
      headers: createHeaders(token),
      body: jsonEncode({ 'Gender': gender?.index, 'BirthDate': birthDate, 'Bio': bio}),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao editar perfil");
    }
  }

  static Future<List<FollowUserDto>> getFollowersAsync(
    String profileId,
    int page,
    int rows,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Follow/GetFollowers/$profileId?Page=$page&Rows=$rows'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return FollowUserDto.fromJsonList(jsonList);
    } else {
      throw Exception("Erro ao carregar usuários");
    }
  }

  static Future<List<FollowUserDto>> getFollowingAsync(
    String profileId,
    int page,
    int rows,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Follow/GetFollowing/$profileId?Page=$page&Rows=$rows'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return FollowUserDto.fromJsonList(jsonList);
    } else {
      throw Exception("Erro ao carregar usuários");
    }
  }

  static Future<void> followUser(String profileId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/v1/Follow/FollowUser/$profileId'),
      headers: createHeaders(token),
    );

    if (response.statusCode != 201) {
      throw Exception("Erro ao seguir usuário");
    }
  }

  static Future<void> unfollowUser(String profileId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/Follow/UnfollowUser/$profileId'),
      headers: createHeaders(token),
    );

    if (response.statusCode != 204) {
      throw Exception("Erro ao deixar de seguir usuário");
    }
  }

  static Future<PostDto> getPostAsync(String postId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Post/$postId/getPost'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      return PostDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erro ao carregar post");
    }
  }

  static Future<List<PostDto>> getPostsByProfileIdAsync(String profileId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Profile/$profileId/getPosts'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return PostDto.fromJsonList(jsonList);
    } else {
      throw Exception("Erro ao carregar post");
    }
  }

  static Future<List<PostDto>> getActivityFeedAsync() async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/ActivityFeed/BuildActivityFeed'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return PostDto.fromJsonList(jsonList);
    } else {
      throw Exception("Erro ao carregar posts");
    }
  }

  static Future<PostDto> createPostAsync(
    String content,
      PostVisibility visibility,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/v1/Post/createPost'),
      headers: createHeaders(token),
      body: jsonEncode({'content': content, 'visibility': visibilityToIntMap[visibility]}),
    );

    if (response.statusCode == 201) {
      return PostDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erro ao criar post");
    }
  }

  static Future<PostDto> editPostAsync(String postId, String? content, PostVisibility? visibility) async {
    var token = await AuthenticationService.getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/v1/Post/$postId/editPost'),
      headers: createHeaders(token),
      body: jsonEncode({
        'content': content,
        'visibility': visibility != null ? visibilityToIntMap[visibility] : null
      }),
    );

    if (response.statusCode == 201) {
      return PostDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erro ao editar post");
    }
  }

  static Future<void> uploadFilesAsync(String id, List<String> filePaths, List<String> filesToKeep) async {
    var token = await AuthenticationService.getToken();

    var uri = Uri.parse('$baseUrl/v1/Post/$id/uploadPostImages');
    var request = http.MultipartRequest('PUT', uri);

    for (String filePath in filePaths) {
      request.files.add(await http.MultipartFile.fromPath(
        'files',
        filePath
      ));
    }

    for (String fileToKeep in filesToKeep) {
      request.fields.addAll({'filesToKeep': fileToKeep});
    }

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    var response = await request.send();

    if (response.statusCode == 204) {
      print("Arquivos enviados com sucesso!");
    } else {
      throw Exception("Erro ao enviar arquivos: ${response.statusCode}");
    }
  }

  static Future<List<PostReactionDto>> getPostReactionsAsync(
    String postId,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Post/$postId/getReactions'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return PostReactionDto.fromJsonList(jsonList);
    } else {
      throw Exception("Erro ao carregar reações");
    }
  }

  static Future<void> reactToPostAsync(
      String postId,
      ReactionType reactionType,
      ) async {
    var token = await AuthenticationService.getToken();

    final url = '$baseUrl/v1/Post/$postId/react';
    final headers = createHeaders(token);
    final body = jsonEncode({
      'reactionType': reactionTypeMap[reactionType]
    });

    print('Request URL: $url');
    print('Request Headers: $headers');
    print('Request Body: $body');

    final response = await http.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode != 204) {
      throw Exception("Erro ao reagir ao post");
    }
  }

  static Future<void> deleteReactionAsync(String postId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/Post/$postId/deleteReaction'),
      headers: createHeaders(token),
    );

    if (response.statusCode != 204) {
      throw Exception("Erro ao deletar reação");
    }
  }

  static Future<List<PostCommentDto>> getPostCommentsAsync(
    String postId,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Post/$postId/getComments'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return PostCommentDto.fromJsonList(jsonList);
    } else {
      throw Exception("Erro ao carregar comentários");
    }
  }

  static Future<void> commentOnPostAsync(String postId, String content) async {
    var token = await AuthenticationService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/v1/Post/$postId/commentOnPost'),
      headers: createHeaders(token),
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 201) {
      throw Exception("Erro ao comentar no post");
    }
  }

  static Future<void> deleteCommentAsync(String commentId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/Post/$commentId/deleteComment'),
      headers: createHeaders(token),
    );

    if (response.statusCode != 204) {
      throw Exception("Erro ao deletar comentário");
    }
  }

  static Future<void> editPostCommentAsync(String commentId, String content) async {
    var token = await AuthenticationService.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/v1/Post/$commentId/editComment'),
      headers: createHeaders(token),
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 204) {
      throw Exception("Erro ao editar post");
    }
  }

  static Future<void> deletePostAsync(String postId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/Post/$postId/deletePost'),
      headers: createHeaders(token),
    );

    if (response.statusCode != 204) {
      throw Exception("Erro ao deletar post");
    }
  }

  static Future<List<FriendRecommendationDto>> getFriendRecommendationsAsync() async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Recommendation/friendRecommendations'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return FriendRecommendationDto.fromJsonList(jsonList);
    } else {
      throw Exception("Erro ao carregar recomendações de amizade");
    }
  }

  static Future<void> sendFriendRequestAsync(
    String profileId,
    String? requestMessage,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/v1/Friend/sendFriendRequest'),
      headers: createHeaders(token),
      body: jsonEncode({
        'requestMessage': requestMessage,
        'friendId': profileId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Erro ao enviar solicitação de amizade");
    }
  }

  static Future<List<FriendDto>> getFriendsAsync(
    String profileId,
    int page,
    int rows,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Friend/listFriends/$profileId?page=$page&rows=$rows'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return FriendDto.fromJsonList(jsonList);
    } else {
      throw Exception("Erro ao carregar amigos");
    }
  }

  static Future<List<FriendRequestDto>> getFriendRequestsAsync() async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Friend/checkRequestStatus'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return FriendRequestDto.fromJsonList(jsonList);
    } else {
      throw Exception("Erro ao carregar solicitações de amizade");
    }
  }

  static Future<void> manageFriendRequestAsync(
    String profileId,
    bool accept,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/v1/Friend/manageFriendRequests'),
      headers: createHeaders(token),
      body: jsonEncode({'profileId': profileId, 'accept': accept}),
    );

    if (response.statusCode != 204) {
      throw Exception("Erro ao gerenciar solicitação de amizade");
    }
  }

  static Future<void> deleteFriendAsync(String profileId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/Friend/removeFriend/$profileId'),
      headers: createHeaders(token),
    );

    if (response.statusCode != 204) {
      throw Exception("Erro ao deletar amigo");
    }
  }

  static Future<void> removeFriendRequestAsync(String profileId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/Friend/removeFriendRequest/$profileId'),
      headers: createHeaders(token),
    );

    if (response.statusCode != 204) {
      throw Exception("Erro ao remover solicitação de amizade");
    }
  }

  static Future<void> uploadProfilePictureAsync(String filePath) async {
    var token = await AuthenticationService.getToken();

    var uri = Uri.parse('$baseUrl/v1/Profile/uploadProfilePicture');
    var request = http.MultipartRequest('PUT', uri);

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      filePath,
    ));

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    var response = await request.send();

    if (response.statusCode == 204) {
      print("Imagem de perfil enviada com sucesso!");
    } else {
      throw Exception("Erro ao enviar imagem de perfil: ${response.statusCode}");
    }
  }

  static Future<List<SimplifiedProfileDto>> searchProfileByNameAsync(
    String name,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Profile/searchProfileByName?Name=$name'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return SimplifiedProfileDto.fromJsonList(jsonList);
    } else {
      throw Exception("Erro ao pesquisar perfil");
    }
  }
}
