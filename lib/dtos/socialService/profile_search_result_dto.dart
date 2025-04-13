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