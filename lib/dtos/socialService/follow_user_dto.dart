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
