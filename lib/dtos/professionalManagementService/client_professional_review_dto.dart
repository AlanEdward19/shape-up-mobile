class ClientProfessionalReviewDto {
  final String id;
  final String clientId;
  final String professionalId;
  final String clientServicePlanId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClientProfessionalReviewDto(
    this.id,
    this.clientId,
    this.professionalId,
    this.clientServicePlanId,
    this.rating,
    this.comment,
    this.createdAt,
    this.updatedAt,
  );

  factory ClientProfessionalReviewDto.fromJson(Map<String, dynamic> json) {
    return ClientProfessionalReviewDto(
      json['id'],
      json['clientId'],
      json['professionalId'],
      json['clientServicePlanId'],
      json['rating'],
      json['comment'],
      DateTime.parse(json['createdAt']),
      DateTime.parse(json['updatedAt']),
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
