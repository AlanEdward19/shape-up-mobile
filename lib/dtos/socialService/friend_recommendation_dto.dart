import 'package:shape_up_app/dtos/socialService/simplified_profile_dto.dart';

class FriendRecommendationDto {
  final SimplifiedProfileDto Profile;
  final int MutualFriends;

  FriendRecommendationDto(this.Profile, this.MutualFriends);

  factory FriendRecommendationDto.fromJson(Map<String, dynamic> json) {
    return FriendRecommendationDto(
      SimplifiedProfileDto.fromJson(json['profile']),
      json['mutualFriends'],
    );
  }

  static List<FriendRecommendationDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FriendRecommendationDto.fromJson(json)).toList();
  }
}