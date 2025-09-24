import 'package:shape_up_app/dtos/nutritionService/daily_menu_dto.dart';

class UserNutritionDto {
  final String id;
  final String createdBy;
  final String userId;
  final String nutritionManagerId;
  final List<DailyMenuDto> dailyMenus;

  UserNutritionDto({
    required this.id,
    required this.createdBy,
    required this.userId,
    required this.nutritionManagerId,
    required this.dailyMenus,
  });

  factory UserNutritionDto.fromJson(Map<String, dynamic> json) {
    return UserNutritionDto(
      id: json['id'] ?? '',
      createdBy: json['createdBy'] ?? '',
      userId: json['userId'] ?? '',
      nutritionManagerId: json['nutritionManagerId'] ?? '',
      dailyMenus: (json['dailyMenus'] as List<dynamic>)
          .map((menu) => DailyMenuDto.fromJson(menu))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdBy': createdBy,
      'userId': userId,
      'nutritionManagerId': nutritionManagerId,
      'dailyMenus': dailyMenus.map((menu) => menu.toJson()).toList(),
    };
  }

  static List<UserNutritionDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => UserNutritionDto.fromJson(json)).toList();
  }
}
