import 'package:shape_up_app/enums/socialService/friend_request_status.dart';

class FriendRequestDto {
  final String profileId;
  final FriendRequestStatus status;
  final String? message;

  FriendRequestDto(this.profileId, this.status, this.message);

  factory FriendRequestDto.fromJson(Map<String, dynamic> json) {
    return FriendRequestDto(
      json['profileId'],
      friendRequestStatusMap.values.firstWhere((v) => v.name == json['status']),
      json['message'],
    );
  }

  static List<FriendRequestDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FriendRequestDto.fromJson(json)).toList();
  }
}