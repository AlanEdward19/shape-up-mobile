enum MeasureUnit{
  kilogram,
  pound,
  kilometer,
  mile;


  static MeasureUnit getWithString(String value) {
    return MeasureUnit.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => MeasureUnit.kilogram,
    );
  }
}