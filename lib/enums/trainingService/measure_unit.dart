enum MeasureUnit{
  kilogram,
  pound,
  kilometer,
  mile;

  @override
  String toString() {
    return this.name.split('.').last;
  }

  static MeasureUnit getWithString(String value) {
    return MeasureUnit.values.firstWhere(
      (e) => e.toString().toLowerCase() == value.toLowerCase(),
      orElse: () => MeasureUnit.kilogram,
    );
  }
}