import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_professional_review_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_score_dto.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:http/http.dart' as http;

import '../dtos/professionalManagementService/client_dto.dart';

class ProfessionalManagementService {
  static final String baseUrl = dotenv.env['PROFESSIONAL_MANAGEMENT_SERVICE_BASE_URL']!;

  static Map<String, String> createHeaders(String token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    return headers;
  }

  static Future<List<ClientProfessionalReviewDto>> getProfessionalReviewsByIdAsync(String id) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(Uri.parse('$baseUrl/v1/Professional/$id/Review'), headers: createHeaders(token));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return ClientProfessionalReviewDto.fromJsonList(jsonList);
    } else {
      throw Exception('Erro ao listar avaliações do profissional');
    }
  }

  static Future<List<ProfessionalDto>> getProfessionalsAsync() async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(Uri.parse('$baseUrl/v1/Professional'), headers: createHeaders(token));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return ProfessionalDto.fromJsonList(jsonList);
    } else {
      throw Exception('Erro ao listar profissionais');
    }
  }

  static Future<ProfessionalScoreDto> getProfessionalScoreByIdAsync(String id) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(Uri.parse('$baseUrl/v1/Professional/$id/Score'), headers: createHeaders(token));

    if (response.statusCode == 200) {
      return ProfessionalScoreDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao buscar pontuação do profissional');
    }
  }

  static Future<ProfessionalDto> getProfessionalByIdAsync(String id) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(Uri.parse('$baseUrl/v1/Professional/$id'), headers: createHeaders(token));

    if (response.statusCode == 200) {
      return ProfessionalDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao buscar profissional');
    }
  }

  static Future<ClientDto> getClientByIdAsync(String id) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(Uri.parse('$baseUrl/v1/Client/$id'), headers: createHeaders(token));

    if (response.statusCode == 200) {
      return ClientDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao buscar cliente');
    }
  }
}