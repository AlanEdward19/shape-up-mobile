class MicronutrientDetailsDto {
  final double quantity;
  final String unit;

  MicronutrientDetailsDto({
    required this.quantity,
    required this.unit,
  });

  factory MicronutrientDetailsDto.fromJson(Map<String, dynamic> json) {
    return MicronutrientDetailsDto(
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson()
  {
    return {
      'quantity': quantity,
      'unit': unit,
    };
  }

  MicronutrientDetailsDto clone() {
    return MicronutrientDetailsDto(
      quantity: quantity,
      unit: unit,
    );
  }
}
