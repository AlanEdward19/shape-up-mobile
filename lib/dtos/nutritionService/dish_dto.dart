import 'food_dto.dart';
import 'dish_ingredient_dto.dart';

class DishDto {
  final String id;
  final String createdBy;
  final String userId;
  final String name;
  final List<DishIngredientDto> ingredients;

  DishDto({
    required this.id,
    required this.createdBy,
    required this.userId,
    required this.name,
    required this.ingredients,
  });

  factory DishDto.fromJson(Map<String, dynamic> json) {
    return DishDto(
      id: json['id'] ?? '',
      createdBy: json['createdBy'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'],
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((item) => DishIngredientDto.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdBy': createdBy,
      'userId': userId,
      'name': name,
      'ingredients': ingredients.map((f) => f.toJson()).toList(),
    };
  }

  DishDto clone() {
    return DishDto(
      id: id,
      createdBy: createdBy,
      userId: userId,
      name: name,
      ingredients: ingredients.map((f) => f.clone()).toList(),
    );
  }

  static List<DishDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => DishDto.fromJson(json)).toList();
  }
}
