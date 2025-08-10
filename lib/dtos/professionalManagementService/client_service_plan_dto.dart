import 'package:shape_up_app/dtos/professionalManagementService/service_plan_dto.dart';
import 'package:shape_up_app/enums/professionalManagementService/subscription_status.dart';

class ClientServicePlanDto {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final SubscriptionStatus status;
  final String? feedback;
  final ServicePlanDto servicePlan;

  ClientServicePlanDto(
      this.id, this.startDate, this.endDate, this.status, this.feedback, this.servicePlan);

  factory ClientServicePlanDto.fromJson(Map<String, dynamic> json) {
    return ClientServicePlanDto(
      json['id'],
      DateTime.parse(json['startDate']),
      DateTime.parse(json['endDate']),
      subscriptionStatusMap[json['status']]!,
      json['feedback'] as String?,
      ServicePlanDto.fromJson(json['servicePlan']),
    );
  }

  static List<ClientServicePlanDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ClientServicePlanDto.fromJson(json)).toList();
  }
}