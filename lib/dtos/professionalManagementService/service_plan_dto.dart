class ServicePlanDto{
  final String id;
  final String professionalId;
  final String title;
  final String description;
  final int durationInDays;
  final double price;

  ServicePlanDto(this.id, this.professionalId,this.title, this.description, this.durationInDays, this.price);

  factory ServicePlanDto.fromJson(Map<String, dynamic> json) {
    return ServicePlanDto(
      json['id'],
      json['professionalId'],
      json['title'],
      json['description'],
      json['durationInDays'],
      (json['price'] as num).toDouble(),
    );
  }

  static List<ServicePlanDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ServicePlanDto.fromJson(json)).toList();
  }
}