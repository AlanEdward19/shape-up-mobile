import 'package:shape_up_app/enums/trainingService/measure_unit.dart';

class WorkoutExerciseValueObject {
  final String exerciseId;
  double? weight;
  int? repetitions;
  MeasureUnit measureUnit;

  WorkoutExerciseValueObject({
    required this.exerciseId,
    this.weight,
    this.repetitions,
    required this.measureUnit,
  });
}