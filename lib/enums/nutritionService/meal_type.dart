enum MealType {
  Breakfast,
  MorningSnack,
  Lunch,
  AfternoonSnack,
  Dinner,
  Supper
}

Map<int, MealType> mealTypeMap = {
  0: MealType.Breakfast,
  1: MealType.MorningSnack,
  2: MealType.Lunch,
  3: MealType.AfternoonSnack,
  4: MealType.Dinner,
  5: MealType.Supper,
};

Map<MealType, int> mealTypeReverseMap = {
  for (var entry in mealTypeMap.entries) entry.value: entry.key,
};

String mealTypeToString(MealType type) => type.toString().split('.').last;

MealType? mealTypeFromString(String? value) {
  if (value == null) return null;
  return MealType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
    orElse: () => MealType.Breakfast, // fallback seguro
  );
}
