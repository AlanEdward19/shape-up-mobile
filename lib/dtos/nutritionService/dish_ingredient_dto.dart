// dtos/nutritionService/dish_ingredient_dto.dart
import 'food_dto.dart';

class DishIngredientDto {
  final double quantity;
  final FoodDto food;

  DishIngredientDto({
    required this.quantity,
    required this.food,
  });

  factory DishIngredientDto.fromJson(Map<String, dynamic> json) {
    return DishIngredientDto(
      quantity: (json['quantity'] as num).toDouble(),
      food: FoodDto.fromJson(json['food']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'food': food.toJson(),
    };
  }

  DishIngredientDto clone() {
    return DishIngredientDto(
      quantity: quantity,
      food: food.clone(),
    );
  }
}