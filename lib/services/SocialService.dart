import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shape_up_app/models/socialServiceReponses.dart';
import 'package:shape_up_app/services/AuthenticationService.dart';

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
      Uri.parse('$baseUrl/v1/Profile/ViewProfile/id'.replaceAll('id', id)),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      return ProfileDto.fromJson(jsonDecode(response.body));
    }
    else {
      throw Exception("Erro ao carregar perfil");
    }
  }

  static Future<List<FollowUserDto>> getFollowersAsync(
    String profileId,
    int page,
    int rows,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/v1/Follow/GetFollowers/id?Page={page}&Rows={rows}'
            .replaceAll('id', profileId)
            .replaceAll(
              'page',
              page.toString().replaceAll('rows', rows.toString()),
            ),
      ),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return FollowUserDto.fromJsonList(jsonList);
    }

    else {
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
      Uri.parse(
        '$baseUrl/v1/Follow/GetFollowing/id?Page={page}&Rows={rows}'
            .replaceAll('id', profileId)
            .replaceAll(
              'page',
              page.toString().replaceAll('rows', rows.toString()),
            ),
      ),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return FollowUserDto.fromJsonList(jsonList);
    }

    else {
      throw Exception("Erro ao carregar usuários");
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
    }

    else {
      throw Exception("Erro ao carregar posts");
    }
  }
}
