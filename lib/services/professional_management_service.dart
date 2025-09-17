import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_professional_review_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_score_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/service_plan_dto.dart';
import 'package:shape_up_app/enums/professionalManagementService/service_plan_type.dart';
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

  static Future<ServicePlanDto> createServicePlanAsync (String title, String description, int durationInDays, double price, ServicePlanType type) async {
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      'title': title,
      'description': description,
      'durationInDays': durationInDays,
      'price': price,
      'type': type.index,
    });

    final response = await http.post(Uri.parse('$baseUrl/v1/ServicePlan'), headers: createHeaders(token), body: body);

    if (response.statusCode == 201) {
      return ServicePlanDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao criar plano de serviço');
    }
  }

  static Future<ClientDto> deactivateServicePlanFromClientAsync (String clientId, String servicePlanId, String reason) async{
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      'status': 1,
      'reason': reason,
    });

    final response = await http.put(
      Uri.parse('$baseUrl/v1/ServicePlan/$servicePlanId/Client/$clientId'),
      headers: createHeaders(token),
      body: body
    );

    if (response.statusCode == 200) {
      return ClientDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao cancelar plano de serviço do cliente');
    }
  }

  static Future<ClientDto> activateServicePlanToClientAsync (String clientId, String servicePlanId) async{
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      'status': 0,
      'reason': '',
    });

    final response = await http.put(
        Uri.parse('$baseUrl/v1/ServicePlan/$servicePlanId/Client/$clientId'),
        headers: createHeaders(token),
        body: body
    );

    if (response.statusCode == 200) {
      return ClientDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao ativar plano de serviço do cliente');
    }
  }

  static Future<ServicePlanDto> updateServicePlanByIdAsync(String servicePlanId, String? title, String? description, int? durationInDays, double? price, ServicePlanType? type ) async {
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (durationInDays != null) 'durationInDays': durationInDays,
      if (price != null) 'price': price,
      if (type != null) 'type': type.index,
    });

    final response = await http.patch(Uri.parse('$baseUrl/v1/ServicePlan/$servicePlanId'), headers: createHeaders(token), body: body);

    if (response.statusCode == 200) {
      return ServicePlanDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao atualizar plano de serviço');
    }
  }

  static Future<void> deleteServicePlanByIdAsync(String servicePlanId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.delete(Uri.parse('$baseUrl/v1/ServicePlan/$servicePlanId'), headers: createHeaders(token));

    if (response.statusCode != 204) {
      throw Exception('Erro ao deletar plano de serviço');
    }
  }

  static Future<List<ClientDto>> getProfessionalClientsAsync(String professionalId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(Uri.parse('$baseUrl/v1/Professional/$professionalId/Client'), headers: createHeaders(token));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return ClientDto.fromJsonList(jsonList);
    } else {
      throw Exception('Erro ao listar clientes do profissional');
    }
  }

  static Future<ClientDto> addServicePlanToClientAsync (String clientId, String servicePlanId) async{
    var token = await AuthenticationService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/v1/ServicePlan/$servicePlanId/Client/$clientId'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 201) {
      return ClientDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao adicionar plano de serviço ao cliente');
    }
  }

  static Future<ClientProfessionalReviewDto> createProfessionalReviewAsync(String professionalId, String servicePlanId, String? comment, int rating) async {
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      if(comment != null) 'comment': comment,
      'rating': rating,
    });

    final response = await http.post(Uri.parse('$baseUrl/v1/Professional/$professionalId/ServicePlan/$servicePlanId/Review'), headers: createHeaders(token), body: body);

    if (response.statusCode == 201) {
      return ClientProfessionalReviewDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao criar avaliação do profissional');
    }
  }

  static Future<void> deleteProfessionalReviewAsync(String id) async {
    var token = await AuthenticationService.getToken();

    final response = await http.delete(Uri.parse('$baseUrl/v1/Review/$id'), headers: createHeaders(token));

    if (response.statusCode != 204) {
      throw Exception('Erro ao deletar avaliação do profissional');
    }
  }

  static Future<ClientProfessionalReviewDto> updateProfessionalReviewAsync(String id, String? comment, int? rating) async {
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      if (comment != null) 'comment': comment,
      if (rating != null) 'rating': rating,
    });

    final response = await http.patch(Uri.parse('$baseUrl/v1/Review/$id'), headers: createHeaders(token), body: body);

    if (response.statusCode == 200) {
      return ClientProfessionalReviewDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao atualizar avaliação do profissional');
    }

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