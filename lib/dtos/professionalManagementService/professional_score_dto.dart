class ProfessionalScoreDto{
  final String professionalId;
  final double averageScore;
  final int totalReviews;
  final DateTime lastUpdated;

  ProfessionalScoreDto(
    this.professionalId,
    this.averageScore,
    this.totalReviews,
    this.lastUpdated,
  );

  factory ProfessionalScoreDto.fromJson(Map<String, dynamic> json) {
    return ProfessionalScoreDto(
      json['professionalId'],
      (json['averageScore'] as num).toDouble(),
      json['totalReviews'],
      DateTime.parse(json['lastUpdated']),
    );
  }

  static List<ProfessionalScoreDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProfessionalScoreDto.fromJson(json)).toList();
  }
}