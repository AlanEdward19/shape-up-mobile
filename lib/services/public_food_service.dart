import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/dtos/nutritionService/food_dto.dart';

import '../dtos/nutritionService/nutritional_info_dto.dart';

class PublicFoodService {
  static final String baseUrl = dotenv.env['NUTRITION_SERVICE_BASE_URL']!;

  static Map<String, String> createHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  //Lista comidas publicas
  static Future<List<FoodDto>> getPublicFoods({int page = 1, int rows = 10}) async {
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

  //Rota para obter detalhes de uma comida pública
  static Future<FoodDto> getPublicFoodDetails(String foodId) async {
    var token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/PublicFood/$foodId'),
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return FoodDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load food details');
    }
  }

  //Rota para listar comidas públicas não revisadas
  static Future<List<FoodDto>> listUnrevisedPublicFoods({int page = 1, int rows = 10}) async {
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
      throw Exception('Failed to load unrevised public foods');
    }

  }

  //Rota para listar comidas públicas revisadas
  static Future<List<FoodDto>> listRevisedPublicFoods({int page = 1, int rows = 10}) async {
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
      throw Exception('Failed to load revised public foods');
    }
  }

  //Rota para criar uma comida pública
  static Future<FoodDto> createPublicFood({
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
      Uri.parse('$baseUrl/v1/PublicFood'),
      headers: createHeaders(token),
      body: body,
    );
    if (response.statusCode == 201)
    {
      return FoodDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create public food');
    }
  }

  //Rota para editar uma comida pública
  static Future<void> editPublicFood(String foodId, {
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
      Uri.parse('$baseUrl/v1/PublicFood/$foodId'),
      headers: createHeaders(token),
      body: body,
    );
    if (response.statusCode != 204)
    {
      throw Exception('Failed to edit public food');
    }

  }

  //Rota para deletar uma comida pública
  static Future<void> deletePublicFood(String foodId) async {
    var token = await AuthenticationService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/v1/PublicFood/$foodId'),
      headers: createHeaders(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete public food');
    }
  }

  //Rota para aprovar uma comida pública
  static Future<void> approvePublicFood(String foodId) async {
    var token = await AuthenticationService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/v1/PublicFood/$foodId/approve'),
      headers: createHeaders(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to approve public food');
    }
  }

  //Rota para obter uma comida pública pelo código de barras
  static Future<FoodDto> getPublicFoodByBarcode(String barcode) async {
    var token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/PublicFood/byBarCode').replace(queryParameters: {
        'barcode': barcode,
      }),
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return FoodDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load public food by barcode');
    }
  }
}
