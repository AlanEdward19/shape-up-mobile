import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/dtos/nutritionService/user_nutrition_dto.dart';
import 'package:shape_up_app/services/authentication_service.dart';

class UserNutrition{
  static final String baseUrl = dotenv.env['NUTRITION_SERVICE_BASE_URL']!;

  static Map<String, String> createHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  //Rota responsável por criar uma nutrição do usuário.
  static Future<UserNutritionDto> createUserNutrition({
    required String userId,
    required String nutritionManagerId,
    required List<String> dailyMenuIds
  })async{
    final token = await AuthenticationService.getToken();
    final body = jsonEncode({
      'nutritionManagerId': nutritionManagerId,
      'dailyMenuIds': dailyMenuIds
    });
    final response = await http.post(
      Uri.parse('$baseUrl/v1/UserNutrition/$userId'),
      headers: createHeaders(token),
      body: body,
    );
    if (response.statusCode == 201) {
      return UserNutritionDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create user nutrition');
    }
  }

  //Rota responsável por deletar uma nutrição do usuário.
  static Future<void> deleteUserNutrition(String userNutritionId) async {
    final token = await AuthenticationService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/v1/UserNutrition/$userNutritionId'),
      headers: createHeaders(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user nutrition');
    }
  }

  //Rota responsável por editar uma nutrição do usuário.
  static Future<void> editUserNutrition(String userNutritionId, {
    required String nutritionManagerId,
    required List<String> dailyMenuIds
  })async{
    final token = await AuthenticationService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/v1/UserNutrition/$userNutritionId'),
      headers: createHeaders(token),
      body: jsonEncode({
        'nutritionManagerId': nutritionManagerId,
        'dailyMenuIds': dailyMenuIds
      }),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to edit user nutrition');
    }
  }

  //Rota responsável por obter os detalhes de uma nutrição do usuário.
  static Future<UserNutritionDto> getUserNutritionDetails(String userNutritionId) async {
    final token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/UserNutrition/details/$userNutritionId'),
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return UserNutritionDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user nutrition details');
    }
  }

  //Rota responsável por listar as nutrições do usuário.
  static Future<List<UserNutritionDto>> listManagedUserNutritions({
    required String managerId,
    int page = 1,
    int size = 10
}) async {
    final token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/UserNutrition/list/$managerId').replace(queryParameters: {
        'page': page.toString(),
        'rows': size.toString(),
      }),
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      Iterable l = jsonDecode(response.body);
      return List<UserNutritionDto>.from(l.map((model)=> UserNutritionDto.fromJson(model)));
    } else {
      throw Exception('Failed to list user nutritions');
    }
  }

  static Future<UserNutritionDto?> getUserNutritionByUserId(String userId) async {
    final token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/UserNutrition/user/$userId'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      // Se encontrou, retorna o DTO
      return UserNutritionDto.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      print('Failed to get user nutrition. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to get user nutrition');
    }
  }
}