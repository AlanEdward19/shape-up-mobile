enum Gender { male, female }

Map<int, Gender> genderMap = {
  0 : Gender.male,
  1 : Gender.female
};

Map<String, Gender> stringToGenderMap = {
  "Masculino" : Gender.male,
  "Feminino" : Gender.female
};

Map<Gender, String> genderToString = {
  Gender.male : "Masculino",
  Gender.female : "Feminino"
};

const Map<Gender, String> genderToStringMap = {
  Gender.male: 'Male',
  Gender.female: 'Female',
};