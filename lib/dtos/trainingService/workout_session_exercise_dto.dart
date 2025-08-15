import 'package:shape_up_app/dtos/trainingService/exercise_dto.dart';
import 'package:shape_up_app/enums/trainingService/measure_unit.dart';

class WorkoutSessionExerciseDto{
  int? weight;
  int? repetitions;
  MeasureUnit measureUnit;
  ExerciseDto metadata;

  WorkoutSessionExerciseDto({
    this.weight,
    this.repetitions,
    required this.measureUnit,
    required this.metadata,
  });

  factory WorkoutSessionExerciseDto.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionExerciseDto(
      weight: json['weight'],
      repetitions: json['repetitions'],
      measureUnit: MeasureUnit.getWithString(json['measureUnit']),
      metadata: ExerciseDto.fromJson(json['metadata']),
    );
  }

  static List<WorkoutSessionExerciseDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => WorkoutSessionExerciseDto.fromJson(json)).toList();
  }
}