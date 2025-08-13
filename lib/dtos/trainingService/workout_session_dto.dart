import 'package:shape_up_app/dtos/trainingService/workout_session_exercise_dto.dart';
import 'package:shape_up_app/enums/trainingService/workout_status.dart';

class WorkoutSessionDto {
  final String sessionId;
  final String userId;
  final String workoutId;
  final DateTime startedAt;
  DateTime? endedAt;
  WorkoutStatus status;
  List<WorkoutSessionExerciseDto> exercises;

  WorkoutSessionDto({
    required this.sessionId,
    required this.userId,
    required this.workoutId,
    required this.startedAt,
    this.endedAt,
    required this.status,
    required this.exercises,
  });

  factory WorkoutSessionDto.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionDto(
      sessionId: json['sessionId'],
      userId: json['userId'],
      workoutId: json['workoutId'],
      startedAt: DateTime.parse(json['startedAt']),
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      status: WorkoutStatus.values[json['status']],
      exercises: WorkoutSessionExerciseDto.fromJsonList(json['exercises']),
    );
  }

  static List<WorkoutSessionDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => WorkoutSessionDto.fromJson(json)).toList();
  }
}
