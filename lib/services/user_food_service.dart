import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/dtos/nutritionService/food_dto.dart';

import '../dtos/nutritionService/nutritional_info_dto.dart';

class UserFoodService {
  static final String baseUrl = dotenv.env['NUTRITION_SERVICE_BASE_URL']!;

  static Map<String, String> createHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  //Rota para listar comidas
  static Future<List<FoodDto>> listUserFoods({int page = 1, int rows = 10}) async {
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
      return FoodDto.fromJsonList(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load foods');
    }
  }

  //Rota para pegar detalhes de uma comida
  static Future<FoodDto> getUserFoodDetails(String foodId) async {
    var token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/UserFood/$foodId'),
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return FoodDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load food details');
    }
  }

  //Rota para criar uma comida
  static Future<FoodDto> createUserFood({
    required String name,
    String? brand,
    String? barCode,
    required NutritionalInfoDto nutritionalInfo,
  }) async {
    var token = await AuthenticationService.getToken();
    final body = jsonEncode({
      "name": name,
      "brand": brand,
      "barCode": barCode,
      "nutritionalInfo": nutritionalInfo.toJson(),
    });
    final response = await http.post(
      Uri.parse('$baseUrl/v1/UserFood'),
      headers: createHeaders(token),
      body: jsonEncode(body),
    );
    if (response.statusCode == 201) {
      return FoodDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create food');
    }
  }

  //Rota para editar uma comida
  static Future<void> editUserFood(String foodId, {
    required String name,
    String? brand,
    String? barCode,
    required NutritionalInfoDto nutritionalInfo,
  }) async {
    var token = await AuthenticationService.getToken();
    final body = jsonEncode({
      "name": name,
      "brand": brand,
      "barCode": barCode,
      "nutritionalInfo": nutritionalInfo.toJson(),
    });
    final response = await http.put(
      Uri.parse('$baseUrl/v1/UserFood/$foodId'),
      headers: createHeaders(token),
      body: body,
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to edit food');
    }
  }

  //Rota para inserir comidas públicas na lista de comidas do usuário
  static Future<FoodDto> insertPublicFood(String foodId, List<int> publicFoods) async {
    var token = await AuthenticationService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/v1/UserFood/insertPublicFoods/$foodId'),
      headers: createHeaders(token),
      body: jsonEncode(publicFoods),
    );
    if (response.statusCode == 201) {
      return FoodDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to insert public food');
    }
  }

  //Rota para aprovar uma comida, e marcar como revisada
  static Future<FoodDto> approveUserFood(String foodId) async {
    var token = await AuthenticationService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/v1/UserFood/approve/$foodId'),
      headers: createHeaders(token),
    );
    if (response.statusCode == 204) {
      return FoodDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to approve food');
    }
  }

  //Rota para deletar uma comida
  static Future<void> deleteUserFood(String foodId) async {
    var token = await AuthenticationService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/v1/UserFood/$foodId'),
      headers: createHeaders(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete food');
    }
  }

  //Rota para buscar uma comida privada pelo código de barras
  static Future<FoodDto> getUserFoodByBarcode(String barcode) async {
    var token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/UserFood/byBarCode/$barcode'),
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return FoodDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load private food by barcode');
    }
  }
}