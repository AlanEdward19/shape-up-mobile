class FatsDto {
  final double total;
  final double? saturatedFat;
  final double? transFat;
  final double? polyunsaturatedFat;
  final double? monounsaturatedFat;
  final double? cholesterol;

  FatsDto({
    required this.total,
    this.saturatedFat,
    this.transFat,
    this.polyunsaturatedFat,
    this.monounsaturatedFat,
    this.cholesterol,
  });

  factory FatsDto.fromJson(Map<String, dynamic> json) {
    return FatsDto(
      total: (json['total'] as num).toDouble(),
      saturatedFat: json['saturatedFat'] != null ? (json['saturatedFat'] as num).toDouble() : null,
      transFat: json['transFat'] != null ? (json['transFat'] as num).toDouble() : null,
      polyunsaturatedFat: json['polyunsaturatedFat'] != null ? (json['polyunsaturatedFat'] as num).toDouble() : null,
      monounsaturatedFat: json['monounsaturatedFat'] != null ? (json['monounsaturatedFat'] as num).toDouble() : null,
      cholesterol: json['cholesterol'] != null ? (json['cholesterol'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'total': total,
      if (saturatedFat != null) 'saturatedFat': saturatedFat,
      if (transFat != null) 'transFat': transFat,
      if (polyunsaturatedFat != null) 'polyunsaturatedFat': polyunsaturatedFat,
      if (monounsaturatedFat != null) 'monounsaturatedFat': monounsaturatedFat,
      if (cholesterol != null) 'cholesterol': cholesterol,
    };
  }

  FatsDto clone() {
    return FatsDto(
      total: total,
      saturatedFat: saturatedFat,
      transFat: transFat,
      polyunsaturatedFat: polyunsaturatedFat,
      monounsaturatedFat: monounsaturatedFat,
      cholesterol: cholesterol,
    );
  }
}
