import 'package:flutter/foundation.dart';

class PostCommentDto {
  final String profileId;
  final String profileFirstName;
  final String profileLastName;
  final String postId;
  final String createdAt;
  final String profileImageUrl;
  final String content;
  final String id;

  PostCommentDto(
      this.profileId,
      this.profileFirstName,
      this.profileLastName,
      this.postId,
      this.createdAt,
      this.profileImageUrl,
      this.content,
      this.id,
      );

  factory PostCommentDto.fromJson(Map<String, dynamic> json) {
    String profileImageUrl = json['profileImageUrl'];

    if (kDebugMode) {
      profileImageUrl = profileImageUrl.replaceFirst("127.0.0.1", "10.0.2.2");
    }

    return PostCommentDto(
      json['profileId'],
      json['profileFirstName'],
      json['profileLastName'],
      json['postId'],
      json['createdAt'], profileImageUrl,
      json['content'],
      json['id']
    );
  }

  static List<PostCommentDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PostCommentDto.fromJson(json)).toList();
  }
}