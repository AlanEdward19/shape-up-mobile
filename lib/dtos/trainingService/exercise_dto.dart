import 'package:shape_up_app/enums/trainingService/muscle_group.dart';

class ExerciseDto{
  final String id;
  final String name;
  final List<MuscleGroup> muscleGroups;
  final bool requiresWeight;
  final String? imageUrl;
  final String? videoUrl;

  ExerciseDto({
    required this.id,
    required this.name,
    required this.muscleGroups,
    required this.requiresWeight,
    this.imageUrl,
    this.videoUrl,
  });

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    return ExerciseDto(
      id: json['id'],
      name: json['name'],
      muscleGroups: (json['muscleGroups'] as List)
          .map((group) => muscleGroupByString(group))
          .toList(),
      requiresWeight: json['requiresWeight'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
    );
  }

  static List<ExerciseDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ExerciseDto.fromJson(json)).toList();
  }
}