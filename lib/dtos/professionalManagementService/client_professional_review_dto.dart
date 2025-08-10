class ClientProfessionalReviewDto {
  final String id;
  final String clientId;
  final String clientName;
  final String professionalId;
  final String clientServicePlanId;
  final int rating;
  final String comment;
  final DateTime lastUpdatedAt;

  ClientProfessionalReviewDto(
    this.id,
    this.clientId,
    this.clientName,
    this.professionalId,
    this.clientServicePlanId,
    this.rating,
    this.comment,
    this.lastUpdatedAt
  );

  factory ClientProfessionalReviewDto.fromJson(Map<String, dynamic> json) {
    return ClientProfessionalReviewDto(
      json['id'],
      json['clientId'],
      json['clientName'],
      json['professionalId'],
      json['clientServicePlanId'],
      json['rating'],
      json['comment'],
      DateTime.parse(json['lastUpdatedAt'])
    );
  }

  static List<ClientProfessionalReviewDto> fromJsonList(
    List<dynamic> jsonList,
  ) {
    return jsonList
        .map((json) => ClientProfessionalReviewDto.fromJson(json))
        .toList();
  }
}
