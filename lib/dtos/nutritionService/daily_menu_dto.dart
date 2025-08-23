import 'package:shape_up_app/dtos/nutritionService/meal_dto.dart';

class DailyMenuDto {
  final String id;
  final String createdBy;
  final String? dayOfWeek; // Pode ser null (opcional)
  final List<MealDto> meals;

  DailyMenuDto({
    required this.id,
    required this.createdBy,
    required this.dayOfWeek,
    required this.meals,
  });

  factory DailyMenuDto.fromJson(Map<String, dynamic> json) {
    return DailyMenuDto(
      id: json['id'] ?? '',
      createdBy: json['createdBy'] ?? '',
      dayOfWeek: json['dayOfWeek'], // pode ser null
      meals: (json['meals'] as List<dynamic>)
          .map((mealJson) => MealDto.fromJson(mealJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdBy': createdBy,
      'dayOfWeek': dayOfWeek,
      'meals': meals.map((meal) => meal.toJson()).toList(),
    };
  }

  static List<DailyMenuDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => DailyMenuDto.fromJson(json)).toList();
  }
}
