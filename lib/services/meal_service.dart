import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import '../dtos/nutritionService/meal_dto.dart';
import '../enums/nutritionService/meal_type.dart';

class MealService{
  static final String baseUrl = dotenv.env['NUTRITION_SERVICE_BASE_URL']!;

  static Map<String, String> createHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  //Rota responsável por criar uma refeição.

  static Future<MealDto> createMeal({
    required MealType type,
    required String name,
    required List<String> dishIds,
    required List<String> foodIds,
}) async {
    final token = await AuthenticationService.getToken();
    final body = jsonEncode({
      'type': type,
      'name': name,
      'dishIds': dishIds,
      'foodIds': foodIds,
    });
    final response = await http.post(
      Uri.parse('$baseUrl/v1/Meal'),
      headers: createHeaders(token),
      body: body,
    );
    if (response.statusCode == 201) {
      return MealDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create meal');
    }
  }

  //Rota responsável por apagar uma refeição.
  static Future<void> deleteMeal(String mealId) async {
    final token = await AuthenticationService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/v1/Meal/$mealId'),
      headers: createHeaders(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete meal');
    }
  }

  //Rota responsável por editar uma refeição.
  static Future<void> editMeal(String mealId, {
    required String name,
    required MealType type,
    required List<String> dishIds,
    required List<String> foodIds,
  }) async {
    final token = await AuthenticationService.getToken();
    final body = jsonEncode({
      'name': name,
      'type': type,
      'dishIds': dishIds,
      'foodIds': foodIds,
    });
    final response = await http.put(
      Uri.parse('$baseUrl/v1/Meal/$mealId'),
      headers: createHeaders(token),
      body: body,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to edit meal');
    }
  }

  //Rota responsável por buscar uma refeição.
  static Future<MealDto> getMealDetails(String mealId) async {
    final token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/Meal/$mealId'),
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return MealDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get meal details');
    }
  }

  //Rota responsável por listar as refeições do usuário.

  static Future<List<MealDto>> listMeals({int page = 1, int rows = 10}) async {
    final token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/Meal').replace(queryParameters: {
        'page': page.toString(),
        'rows': rows.toString(),
      }),
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return MealDto.fromJsonList(jsonDecode(response.body));
    } else {
      throw Exception('Failed to list meals');
      }
  }
}