import 'package:flutter/foundation.dart';
import 'package:shape_up_app/enums/socialService/gender.dart';

class ProfileDto {
  final String id;
  final String firstName;
  final String lastName;
  final String city;
  final String state;
  final String country;
  final String birthDate;
  final String bio;
  final Gender gender;
  final String email;
  final String imageUrl;
  final int followers;
  final int following;
  final int posts;

  ProfileDto(
      this.id,
      this.firstName,
      this.lastName,
      this.city,
      this.state,
      this.country,
      this.birthDate,
      this.bio,
      this.gender,
      this.email,
      this.imageUrl,
      this.followers,
      this.following,
      this.posts,
      );

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    String birthDate = json.containsKey("birthDate") ? json['birthDate'] : "";
    Gender gender = json.containsKey("gender") ? (genderMap[json["gender"]] ?? Gender.male) : Gender.male;
    String imageUrl = json["imageUrl"];

    if (kDebugMode) {
      imageUrl = imageUrl.replaceFirst("127.0.0.1", "10.0.2.2");
    }

    return ProfileDto(
      json['id'],
      json['firstName'],
      json['lastName'],
      json['city'],
      json['state'],
      json['country'],
      birthDate,
      json['bio'],
      gender,
      json['email'],
      imageUrl,
      json['followers'],
      json['following'],
      json['posts'],
    );
  }

  static List<ProfileDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProfileDto.fromJson(json)).toList();
  }
}