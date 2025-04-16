import 'package:flutter/foundation.dart';

class SimplifiedProfileDto {
  final String id;
  final String firstName;
  final String lastName;
  final String imageUrl;

  SimplifiedProfileDto(this.id, this.firstName, this.lastName, this.imageUrl);

  factory SimplifiedProfileDto.fromJson(Map<String, dynamic> json) {
    String imageUrl = json["imageUrl"];

    if (kDebugMode) {
      imageUrl = imageUrl.replaceFirst("127.0.0.1", "10.0.2.2");
    }

    return SimplifiedProfileDto(
      json['id'],
      json['firstName'],
      json['lastName'],
      imageUrl
    );
  }

  static List<SimplifiedProfileDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => SimplifiedProfileDto.fromJson(json))
        .toList();
  }
}