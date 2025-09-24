import 'carbohydrates_dto.dart';
import 'fats_dto.dart';

class MacronutrientsDto {
  final double? proteins;
  final CarbohydratesDto? carbohydrates;
  final FatsDto? fats;

  MacronutrientsDto({
    this.proteins,
    this.carbohydrates,
    this.fats,
  });

  factory MacronutrientsDto.fromJson(Map<String, dynamic> json) {
    return MacronutrientsDto(
      proteins: json['proteins'] != null ? (json['proteins'] as num).toDouble() : null,
      carbohydrates: json['carbohydrates'] != null
          ? CarbohydratesDto.fromJson(json['carbohydrates'])
          : null,
      fats: json['fats'] != null ? FatsDto.fromJson(json['fats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (proteins != null) 'proteins': proteins,
      if (carbohydrates != null) 'carbohydrates': carbohydrates!.toJson(),
      if (fats != null) 'fats': fats!.toJson(),
    };
  }

  MacronutrientsDto clone() {
    return MacronutrientsDto(
      proteins: proteins,
      carbohydrates: carbohydrates?.clone(),
      fats: fats?.clone(),
    );
  }
}
