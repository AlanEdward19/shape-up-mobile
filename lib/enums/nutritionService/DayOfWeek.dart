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

Map<String, DayOfWeek> dayOfWeekMap = {
  'Sunday': DayOfWeek.sunday,
  'Monday': DayOfWeek.monday,
  'Tuesday': DayOfWeek.tuesday,
  'Wednesday': DayOfWeek.wednesday,
  'Thursday': DayOfWeek.thursday,
  'Friday': DayOfWeek.friday,
  'Saturday': DayOfWeek.saturday,
  '': DayOfWeek.empty
};

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
