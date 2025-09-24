// dtos/nutritionService/ingredient_input_dto.dart
class IngredientInputDto {
  final String foodId;
  final double quantity;

  IngredientInputDto({required this.foodId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'quantity': quantity,
    };
  }
}