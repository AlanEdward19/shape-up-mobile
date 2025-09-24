import 'macronutrients_dto.dart';
import 'micronutrient_details_dto.dart';

class NutritionalInfoDto {
  final MacronutrientsDto? macronutrients;
  final Map<String, MicronutrientDetailsDto>? micronutrients;
  final double servingSize;
  final double? calories;

  NutritionalInfoDto({
    this.macronutrients,
    this.micronutrients,
    required this.servingSize,
    this.calories,
  });

  factory NutritionalInfoDto.fromJson(Map<String, dynamic> json) {
    return NutritionalInfoDto(
      macronutrients: json['macronutrients'] != null
          ? MacronutrientsDto.fromJson(json['macronutrients'])
          : null,
      micronutrients: json['micronutrients'] != null
          ? Map<String, MicronutrientDetailsDto>.from(
        (json['micronutrients'] as Map).map(
              (key, value) =>
              MapEntry(key, MicronutrientDetailsDto.fromJson(value)),
        ),
      )
          : null,
      servingSize: (json['servingSize'] as num).toDouble(),
      calories: json['calories'] != null ? (json['calories'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (macronutrients != null) 'macronutrients': macronutrients!.toJson(),
      if (micronutrients != null)
        'micronutrients': micronutrients!.map(
              (key, value) => MapEntry(key, value.toJson()),
        ),
      'servingSize': servingSize,
      if (calories != null) 'calories': calories,
    };
  }

  NutritionalInfoDto clone() {
    return NutritionalInfoDto(
      macronutrients: macronutrients?.clone(),
      micronutrients: micronutrients != null
          ? Map<String, MicronutrientDetailsDto>.fromEntries(
        micronutrients!.entries.map(
              (e) => MapEntry(e.key, e.value.clone()),
        ),
      )
          : null,
      servingSize: servingSize,
      calories: calories,
    );
  }
}
