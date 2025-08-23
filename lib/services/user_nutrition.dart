import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/dtos/nutritionService/user_nutrition_dto.dart';
import 'package:shape_up_app/enums/nutritionService/DayOfWeek.dart';
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
    required String nutritionManagerId,
    required List<String> dailyMenuIds
  })async{
    final token = await AuthenticationService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/v1/UserNutrition'),
      headers: createHeaders(token),
      body: jsonEncode({
        'nutritionManagerId': nutritionManagerId,
        'dailyMenuIds': dailyMenuIds
      }),
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
      Uri.parse('$baseUrl/v1/UserNutrition/$userNutritionId'),
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return UserNutritionDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user nutrition details');
    }
  }

  //Rota responsável por listar as nutrições do usuário.
  static Future<List<UserNutritionDto>> listUserNutrition({
    int page = 1,
    int rows = 10
}) async {
    final token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/UserNutrition').replace(queryParameters: {
        'page': page.toString(),
        'rows': rows.toString(),
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
}