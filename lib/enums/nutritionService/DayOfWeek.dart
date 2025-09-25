enum DayOfWeek {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  empty
}

extension DayOfWeekExtension on DayOfWeek {
  String toPortuguese() {
    switch (this) {
      case DayOfWeek.sunday:
        return 'Domingo';
      case DayOfWeek.monday:
        return 'Segunda-feira';
      case DayOfWeek.tuesday:
        return 'Terça-feira';
      case DayOfWeek.wednesday:
        return 'Quarta-feira';
      case DayOfWeek.thursday:
        return 'Quinta-feira';
      case DayOfWeek.friday:
        return 'Sexta-feira';
      case DayOfWeek.saturday:
        return 'Sábado';
      case DayOfWeek.empty:
        return 'Dia não especificado';
    }
  }
}

String dayOfWeekToPortugueseString(DayOfWeek day) {
  return day.toPortuguese();
}

Map<DayOfWeek, String> dayOfWeekToStringMap = {
  DayOfWeek.sunday: 'Sunday',
  DayOfWeek.monday: 'Monday',
  DayOfWeek.tuesday: 'Tuesday',
  DayOfWeek.wednesday: 'Wednesday',
  DayOfWeek.thursday: 'Thursday',
  DayOfWeek.friday: 'Friday',
  DayOfWeek.saturday: 'Saturday',
  DayOfWeek.empty: ''
};
