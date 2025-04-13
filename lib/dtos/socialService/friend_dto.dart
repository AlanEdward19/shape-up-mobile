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