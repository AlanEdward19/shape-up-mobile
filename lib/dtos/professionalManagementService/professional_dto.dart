import 'package:shape_up_app/dtos/professionalManagementService/service_plan_dto.dart';
import 'package:shape_up_app/enums/professionalManagementService/professional_type.dart';

class ProfessionalDto{
  final String id;
  final String email;
  final String name;
  final ProfessionalType type;
  final bool isVerified;
  final List<ServicePlanDto> servicePlans;

  ProfessionalDto(this.id, this.email, this.name, this.type, this.isVerified, this.servicePlans);

  factory ProfessionalDto.fromJson(Map<String, dynamic> json) {
    return ProfessionalDto(
      json['id'],
      json['email'],
      json['name'],
      professionalTypeMap[json['type']]!,
      json['isVerified'],
      ServicePlanDto.fromJsonList(json['servicePlans']),
    );
  }

  static List<ProfessionalDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProfessionalDto.fromJson(json)).toList();
  }

}