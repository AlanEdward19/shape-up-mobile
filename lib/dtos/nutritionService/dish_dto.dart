import 'food_dto.dart';

class DishDto {
  final String id;
  final String createdBy;
  final String name;
  final List<FoodDto> foods;

  DishDto({
    required this.id,
    required this.createdBy,
    required this.name,
    required this.foods,
  });

  factory DishDto.fromJson(Map<String, dynamic> json) {
    return DishDto(
      id: json['id'] ?? '',
      createdBy: json['createdBy'] ?? '',
      name: json['name'],
      foods: (json['foods'] as List<dynamic>)
          .map((item) => FoodDto.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdBy': createdBy,
      'name': name,
      'foods': foods.map((f) => f.toJson()).toList(),
    };
  }

  DishDto clone() {
    return DishDto(
      id: id,
      createdBy: createdBy,
      name: name,
      foods: foods.map((f) => f.clone()).toList(),
    );
  }

  static List<DishDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => DishDto.fromJson(json)).toList();
  }
}
