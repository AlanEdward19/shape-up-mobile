enum MeasureUnit{
  kilogram,
  pound,
  kilometer,
  mile;

  @override
  String toString() {
    switch (this) {
      case MeasureUnit.kilogram:
        return 'kg';
      case MeasureUnit.pound:
        return 'lb';
      case MeasureUnit.kilometer:
        return 'km';
      case MeasureUnit.mile:
        return 'mi';
    }
  }
}