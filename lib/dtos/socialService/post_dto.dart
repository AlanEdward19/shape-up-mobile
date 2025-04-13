import 'package:flutter/foundation.dart';
import 'package:shape_up_app/enums/socialService/visibility.dart';

class PostDto {
  final String id;
  final String publisherId;
  final String publisherFirstName;
  final String publisherLastName;
  final String publisherImageUrl;
  final Visibility visibility;
  final List<String> images;
  final String content;

  PostDto(
      this.id,
      this.publisherId,
      this.publisherFirstName,
      this.publisherLastName,
      this.publisherImageUrl,
      this.visibility,
      this.images,
      this.content,
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
    );
  }

  static List<PostDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PostDto.fromJson(json)).toList();
  }
}