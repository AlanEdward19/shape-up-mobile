class SugarDetailsDto {
  final double total;
  final double? addedSugar;
  final double? sugarAlcohols;

  SugarDetailsDto({
    required this.total,
    this.addedSugar,
    this.sugarAlcohols,
  });

  factory SugarDetailsDto.fromJson(Map<String, dynamic> json) {
    return SugarDetailsDto(
      total: (json['total'] as num).toDouble(),
      addedSugar: json['addedSugar'] != null ? (json['addedSugar'] as num).toDouble() : null,
      sugarAlcohols: json['sugarAlcohols'] != null ? (json['sugarAlcohols'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      if (addedSugar != null) 'addedSugar': addedSugar,
      if (sugarAlcohols != null) 'sugarAlcohols': sugarAlcohols,
    };
  }

  SugarDetailsDto clone() {
    return SugarDetailsDto(
      total: total,
      addedSugar: addedSugar,
      sugarAlcohols: sugarAlcohols,
    );
  }
}
