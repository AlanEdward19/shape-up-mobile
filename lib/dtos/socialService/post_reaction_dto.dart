import 'package:shape_up_app/enums/socialService/reaction_type.dart';

class PostReactionDto {
  final String profileId;
  final String createdAt;
  final ReactionType reactionType;
  final String postId;
  final String id;

  PostReactionDto(
      this.profileId,
      this.createdAt,
      this.reactionType,
      this.postId,
      this.id,
      );

  factory PostReactionDto.fromJson(Map<String, dynamic> json) {
    return PostReactionDto(
      json['profileId'],
      json['createdAt'],
      ReactionType.values.firstWhere((e) => e.name == json['reactionType'].toString().toLowerCase()),
      json['postId'],
      json['id'],
    );
  }

  static List<PostReactionDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PostReactionDto.fromJson(json)).toList();
  }
}