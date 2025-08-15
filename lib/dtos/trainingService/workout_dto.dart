import 'package:shape_up_app/dtos/trainingService/exercise_dto.dart';
import 'package:shape_up_app/enums/trainingService/workout_visibility.dart';

class WorkoutDto{
  final String id;
  final String creatorId;
  final String userId;
  final String name;
  WorkoutVisibility visibility;
  List<ExerciseDto> exercises;

  WorkoutDto({
    required this.id,
    required this.creatorId,
    required this.userId,
    required this.name,
    required this.visibility,
    required this.exercises,
  });

  factory WorkoutDto.fromJson(Map<String, dynamic> json) {
    return WorkoutDto(
      id: json['id'],
      creatorId: json['creatorId'],
      userId: json['userId'],
      name: json['name'],
      visibility: WorkoutVisibility.getWithString(json['visibility']),
      exercises: ExerciseDto.fromJsonList(json['exercises']),
    );
  }

  static List<WorkoutDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => WorkoutDto.fromJson(json)).toList();
  }
}