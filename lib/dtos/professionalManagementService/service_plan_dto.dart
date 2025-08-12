import 'package:shape_up_app/enums/professionalManagementService/service_plan_type.dart';

class ServicePlanDto {
  final String id;
  final String professionalId;
  final String title;
  final String description;
  final int durationInDays;
  final double price;
  final ServicePlanType type;

  ServicePlanDto(
    this.id,
    this.professionalId,
    this.title,
    this.description,
    this.durationInDays,
    this.price,
    this.type,
  );

  factory ServicePlanDto.fromJson(Map<String, dynamic> json) {
    return ServicePlanDto(
      json['id'],
      json['professionalId'],
      json['title'],
      json['description'],
      json['durationInDays'],
      (json['price'] as num).toDouble(),
      professionalTypeMap[json['type']]!,
    );
  }

  static List<ServicePlanDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ServicePlanDto.fromJson(json)).toList();
  }
}
