class UserData{
  String firstName;
  String lastName;
  String country;
  String postalCode;
  String birthDay;

  UserData({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.postalCode,
    required this.birthDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'country': country,
      'postalCode': postalCode,
      'birthDay': birthDay,
    };
  }
}