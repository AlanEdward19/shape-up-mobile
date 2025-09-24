import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/enums/nutritionService/DayOfWeek.dart';
import 'package:shape_up_app/services/authentication_service.dart';

import '../dtos/nutritionService/daily_menu_dto.dart';

class DailyMenuService{
  static final String baseUrl = dotenv.env['NUTRITION_SERVICE_BASE_URL']!;

  static Map<String, String> createHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  //Rota para criar um novo cardápio diário.
  static Future<DailyMenuDto> createDailyMenuForOwnUser({
    DayOfWeek? dayOfWeek,
    required List<String> mealIds,
}) async {
    final token = await AuthenticationService.getToken();
    final body = jsonEncode({
      'dayOfWeek': dayOfWeekToStringMap[dayOfWeek],
      'mealIds': mealIds,
    });
    final response = await http.post(
      Uri.parse('$baseUrl/v1/DailyMenu'),
      headers: createHeaders(token),
      body: body,
    );
    if (response.statusCode == 201) {
      return DailyMenuDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create daily menu');
    }
  }

  //Rota para criar um novo cardápio diário para outro usuário.
  static Future<DailyMenuDto> createDailyMenuForDifferentUser({
    required String userId,
    DayOfWeek? dayOfWeek,
    required List<String> mealIds,
  }) async {
    final token = await AuthenticationService.getToken();
    final body = jsonEncode({
      'dayOfWeek': dayOfWeekToStringMap[dayOfWeek],
      'mealIds': mealIds,
    });
    final response = await http.post(
      Uri.parse('$baseUrl/v1/DailyMenu/$userId'),
      headers: createHeaders(token),
      body: body,
    );
    if (response.statusCode == 201) {
      return DailyMenuDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create daily menu');
    }
  }

  //Rota para deletar um cardápio diário.
  static Future<void> deleteDailyMenu(String dailyMenuId) async {
    final token = await AuthenticationService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/v1/DailyMenu/$dailyMenuId'),
      headers: createHeaders(token),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete daily menu');
    }
  }

  //Rota para editar um cardápio diário.
  static Future<void> editDailyMenu(String dailyMenuId, {
    DayOfWeek? dayOfWeek,
    required List<String> mealIds,
  }) async {
    final token = await AuthenticationService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/v1/DailyMenu/$dailyMenuId'),
      headers: createHeaders(token),
      body: jsonEncode({
        'dayOfWeek': dayOfWeekToStringMap[dayOfWeek],
        'mealIds': mealIds,
      }),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to edit daily menu');
    }
  }

  //Rota para obter os detalhes de um cardápio diário específico.
  static Future<DailyMenuDto> getDailyMenuDetails(String dailyMenuId) async {
    final token = await AuthenticationService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/v1/DailyMenu/details/$dailyMenuId'),
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return DailyMenuDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get daily menu details');
    }
  }

  //Rota para listar os cardápios diários com base em critérios de pesquisa.
  static Future<List<DailyMenuDto>> listDailyMenus(String userId, {
    DayOfWeek? dayOfWeek,
    int page = 1,
    int size = 10,
  }) async {
    final token = await AuthenticationService.getToken();
    final uri = Uri.parse('$baseUrl/v1/DailyMenu/list/$userId').replace(queryParameters: {
      'dayOfWeek': dayOfWeekToStringMap[dayOfWeek],
      'page': page.toString(),
      'rows': size.toString(),
    });
    final response = await http.get(
      uri,
      headers: createHeaders(token),
    );
    if (response.statusCode == 200) {
      return DailyMenuDto.fromJsonList(jsonDecode(response.body));
    } else {
      throw Exception('Failed to list daily menus');
    }
  }
}