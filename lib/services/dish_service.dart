import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/dtos/nutritionService/food_dto.dart';

import '../dtos/nutritionService/dish_dto.dart';

class DishService{
  static final String baseUrl = dotenv.env['NUTRITION_SERVICE_BASE_URL']!;

  static Map<String, String> createHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  //Rota para obter detalhes de um prato
  static Future<DishDto> getDishDetails(String dishId) async {
    var token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/Dish/$dishId'),
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return DishDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dish details');
    }
  }

  //Rota para listar pratos
  static Future<List<DishDto>> listDishes({int page = 1, int rows = 10}) async {
    var token = await AuthenticationService.getToken();
    final uri = Uri.parse('$baseUrl/v1/PublicFood').replace(queryParameters: {
      'page': page.toString(),
      'rows': rows.toString(),
    });

    final response = await http.get(
      uri,
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return DishDto.fromJsonList(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dishes');
    }
  }

  // Rota para criar um prato
  static Future<DishDto> createDish({
    required String name,
    required List<String> foodIds,
  }) async {
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      'name': name,
      'foodIds': foodIds,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/v1/Dish'),
      headers: createHeaders(token),
      body: body,
    );

    if (response.statusCode == 201) {
      return DishDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create dish: ${response.statusCode} - ${response.body}');
    }
  }


  //Rota para atualizar um prato
  static Future<void> updateDish(String dishId, {
    required String name,
    required List<String> foodIds,
  }) async {
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      'name': name,
      'foodIds': foodIds,
    });

    final response = await http.put(
      Uri.parse('$baseUrl/v1/Dish/$dishId'),
      headers: createHeaders(token),
      body: body,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to update dish');
    }
  }

  //Rota para deletar um prato
  static Future<void> deleteDish(String dishId) async {
    var token = await AuthenticationService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/v1/Dish/$dishId'),
      headers: createHeaders(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete dish');
    }
  }
}