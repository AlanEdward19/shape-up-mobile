import 'package:flutter/foundation.dart';
import 'package:shape_up_app/enums/socialService/post_visibility.dart';
import 'package:shape_up_app/enums/socialService/reaction_type.dart';

class PostDto {
  final String id;
  final String publisherId;
  final String publisherFirstName;
  final String publisherLastName;
  final String publisherImageUrl;
  final PostVisibility visibility;
  final List<String> images;
  final String content;
  int reactionsCount;
  int commentsCount;
  List<ReactionType> topReactions;
  bool hasUserReacted;
  bool hasUserCommented;

  PostDto(
      this.id,
      this.publisherId,
      this.publisherFirstName,
      this.publisherLastName,
      this.publisherImageUrl,
      this.visibility,
      this.images,
      this.content,
      this.reactionsCount,
      this.commentsCount,
      this.topReactions,
      this.hasUserReacted,
      this.hasUserCommented,
      );

  factory PostDto.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['publisherImageUrl'];
    List<String> postImages = List<String>.from(json['images']);

    if (kDebugMode) {
      imageUrl = imageUrl.replaceFirst("127.0.0.1", "10.0.2.2");

      for (int i = 0; i < postImages.length; i++) {
        var image = postImages[i];

        postImages[i] = image.replaceFirst("127.0.0.1", "10.0.2.2");
      }
    }

    return PostDto(
      json['id'],
      json['publisherId'],
      json['publisherFirstName'],
      json['publisherLastName'],
      imageUrl,
      visibilityMap[json['visibility']]!,
      postImages,
      json['content'],
      json['reactionsCount'],
      json['commentsCount'],
      (json['topReactions'] as List<dynamic>)
          .map((reaction) => intReactionTypeMap[reaction]!)
          .toList(),
      json['hasUserReacted'],
      json['hasUserCommented']
    );
  }

  static List<PostDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PostDto.fromJson(json)).toList();
  }
}