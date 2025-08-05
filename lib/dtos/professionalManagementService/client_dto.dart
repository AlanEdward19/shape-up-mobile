import 'package:shape_up_app/dtos/professionalManagementService/client_professional_review_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_service_plan_dto.dart';

class ClientDto{
  final String id;
  final String email;
  final List<ClientServicePlanDto> servicePlans;
  final List<ClientProfessionalReviewDto> reviews;

  ClientDto(this.id, this.email, this.servicePlans, this.reviews);

  factory ClientDto.fromJson(Map<String, dynamic> json) {
    return ClientDto(
      json['id'],
      json['email'],
      ClientServicePlanDto.fromJsonList(json['clientServicePlans']),
      ClientProfessionalReviewDto.fromJsonList(json['clientProfessionalReviews']),
    );
  }

  static List<ClientDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ClientDto.fromJson(json)).toList();
  }
}