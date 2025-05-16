class UserData{
  String firstName;
  String lastName;
  String country;
  String city;
  String state;
  String postalCode;
  String birthDay;

  UserData({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.birthDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'country': country,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'birthDay': birthDay,
    };
  }
}