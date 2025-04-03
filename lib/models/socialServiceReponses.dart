import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

enum Gender { male, female }

enum Visibility { public, friendsOnly, private }

enum ReactionType {
  like,
  dislike,
  love,
  haha,
  wow,
  sad,
  angry,
  care,
  support,
  celebrate,
}

const Map<int, Visibility> visibilityMap = {
  0: Visibility.public,
  1: Visibility.friendsOnly,
  2: Visibility.private,
};

const Map<ReactionType, String> reactionEmojiMap = {
  ReactionType.like: "👍",
  ReactionType.dislike: "👎",
  ReactionType.love: "❤️",
  ReactionType.haha: "😄",
  ReactionType.wow: "😮",
  ReactionType.sad: "😢",
  ReactionType.angry: "😠",
  ReactionType.care: "🤗",
  ReactionType.support: "💪",
  ReactionType.celebrate: "🎉",
};

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
    return ProfileDto(
      json['id'],
      json['firstName'],
      json['lastName'],
      json['city'],
      json['state'],
      json['country'],
      json['birthDate'],
      json['bio'],
      Gender.values.firstWhere((v) => v.name == json['gender']),
      json['email'],
      json['imageUrl'],
      json['followers'],
      json['following'],
      json['posts'],
    );
  }

  static List<ProfileDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ProfileDto.fromJson(json)).toList();
  }
}

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

class FollowUserDto {
  final String profileId;
  final String firstName;
  final String lastName;
  final String imageUrl;

  FollowUserDto(this.profileId, this.firstName, this.lastName, this.imageUrl);

  factory FollowUserDto.fromJson(Map<String, dynamic> json) {
    return FollowUserDto(
      json['profileId'],
      json['firstName'],
      json['lastName'],
      json['imageUrl'],
    );
  }

  static List<FollowUserDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FollowUserDto.fromJson(json)).toList();
  }
}
