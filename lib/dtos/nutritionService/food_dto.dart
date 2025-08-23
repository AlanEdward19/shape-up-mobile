import 'nutritional_info_dto.dart';

class FoodDto {
  final String id;
  final String createdBy;
  final String name;
  final String? brand;
  final String? barCode;
  final bool isRevised;
  final NutritionalInfoDto nutritionalInfo;

  FoodDto({
    required this.id,
    required this.createdBy,
    required this.name,
    this.brand,
    this.barCode,
    required this.isRevised,
    required this.nutritionalInfo,
  });

  factory FoodDto.fromJson(Map<String, dynamic> json) {
    return FoodDto(
      id: json['id'] ?? '',
      createdBy: json['createdBy'] ?? '',
      name: json['name'],
      brand: json['brand'],
      barCode: json['barCode'],
      isRevised: json['revised'] ?? false,
      nutritionalInfo: NutritionalInfoDto.fromJson(json['nutritionalInfo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdBy': createdBy,
      'name': name,
      if (brand != null) 'brand': brand,
      if (barCode != null) 'barCode': barCode,
      'revised': isRevised,
      'nutritionalInfo': nutritionalInfo.toJson(),
    };
  }

  FoodDto clone() {
    return FoodDto(
      id: id,
      createdBy: createdBy,
      name: name,
      brand: brand,
      barCode: barCode,
      isRevised: isRevised,
      nutritionalInfo: nutritionalInfo.clone(),
    );
  }

  static List<FoodDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FoodDto.fromJson(json)).toList();
  }
}
