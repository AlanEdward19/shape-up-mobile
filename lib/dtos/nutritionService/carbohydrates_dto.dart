import 'sugar_details_dto.dart';

class CarbohydratesDto {
  final double total;
  final double? dietaryFiber;
  final SugarDetailsDto? sugar;

  CarbohydratesDto({
    required this.total,
    this.dietaryFiber,
    this.sugar,
  });

  factory CarbohydratesDto.fromJson(Map<String, dynamic> json) {
    return CarbohydratesDto(
      total: (json['total'] as num).toDouble(),
      dietaryFiber: json['dietaryFiber'] != null
          ? (json['dietaryFiber'] as num).toDouble()
          : null,
      sugar: json['sugar'] != null
          ? SugarDetailsDto.fromJson(json['sugar'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      if (dietaryFiber != null) 'dietaryFiber': dietaryFiber,
      if (sugar != null) 'sugar': sugar!.toJson(),
    };
  }

  CarbohydratesDto clone() {
    return CarbohydratesDto(
      total: total,
      dietaryFiber: dietaryFiber,
      sugar: sugar?.clone(),
    );
  }
}
