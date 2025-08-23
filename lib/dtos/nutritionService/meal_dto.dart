import 'package:shape_up_app/enums/nutritionService/meal_type.dart';
import 'package:shape_up_app/dtos/nutritionService/food_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/dish_dto.dart';

class MealDto {
  final String id;
  final String createdBy;
  final MealType type;
  final String name;
  final List<DishDto> dishes;
  final List<FoodDto> foods;

  MealDto({
    required this.id,
    required this.createdBy,
    required this.type,
    required this.name,
    required this.dishes,
    required this.foods,
  });

  factory MealDto.fromJson(Map<String, dynamic> json) {
    return MealDto(
      id: json['id'] ?? '',
      createdBy: json['createdBy'] ?? '',
      type: mealTypeMap[json['type']] ?? MealType.Breakfast,
      name: json['name'] ?? '',
      dishes: (json['dishes'] as List<dynamic>)
          .map((dishJson) => DishDto.fromJson(dishJson))
          .toList(),
      foods: (json['foods'] as List<dynamic>)
          .map((foodJson) => FoodDto.fromJson(foodJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdBy': createdBy,
      'type': mealTypeMap.entries.firstWhere((e) => e.value == type).key,
      'name': name,
      'dishes': dishes.map((dish) => dish.toJson()).toList(),
      'foods': foods.map((food) => food.toJson()).toList(),
    };
  }

  static List<MealDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MealDto.fromJson(json)).toList();
  }
}
