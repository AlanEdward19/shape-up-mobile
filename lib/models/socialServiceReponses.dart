import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

enum Gender { male, female }

enum FriendRequestStatus { Pending, PendingResponse }

const Map<int, FriendRequestStatus> friendRequestStatusMap = {
  0: FriendRequestStatus.Pending,
  1: FriendRequestStatus.PendingResponse,
};

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

const Map<ReactionType, int> reactionTypeMap = {
  ReactionType.like : 0,
  ReactionType.dislike : 1,
  ReactionType.love : 2,
  ReactionType.haha : 3,
  ReactionType.wow : 4,
  ReactionType.sad : 5,
  ReactionType.angry : 6,
  ReactionType.care : 7,
  ReactionType.support : 8,
  ReactionType.celebrate : 9,
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
  ReactionType.celebrate: "🎉"
};

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

class PostCommentDto {
  final String profileId;
  final String profileFirstName;
  final String profileLastName;
  final String postId;
  final String createdAt;
  final String content;
  final String id;

  PostCommentDto(
    this.profileId,
    this.profileFirstName,
    this.profileLastName,
    this.postId,
    this.createdAt,
    this.content,
    this.id,
  );

  factory PostCommentDto.fromJson(Map<String, dynamic> json) {
    return PostCommentDto(
      json['profileId'],
      json['profileFirstName'],
      json['profileLastName'],
      json['postId'],
      json['createdAt'],
      json['content'],
      json['id'],
    );
  }

  static List<PostCommentDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PostCommentDto.fromJson(json)).toList();
  }
}

class ProfileSearchResultDto {
  final String id;
  final String firstName;
  final String lastName;
  final String imageUrl;

  ProfileSearchResultDto(this.id, this.firstName, this.lastName, this.imageUrl);

  factory ProfileSearchResultDto.fromJson(Map<String, dynamic> json) {
    return ProfileSearchResultDto(
      json['id'],
      json['firstName'],
      json['lastName'],
      json['imageUrl'],
    );
  }

  static List<ProfileSearchResultDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ProfileSearchResultDto.fromJson(json))
        .toList();
  }
}

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

class FriendDto {
  final String profileId;
  final String firstName;
  final String lastName;
  final String imageUrl;

  FriendDto(this.profileId, this.firstName, this.lastName, this.imageUrl);

  factory FriendDto.fromJson(Map<String, dynamic> json) {
    return FriendDto(
      json['profileId'],
      json['firstName'],
      json['lastName'],
      json['imageUrl'],
    );
  }

  static List<FriendDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FriendDto.fromJson(json)).toList();
  }
}

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
