import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shape_up_app/dtos/trainingService/exercise_dto.dart';
import 'package:shape_up_app/dtos/trainingService/workout_dto.dart';
import 'package:shape_up_app/dtos/trainingService/workout_session_dto.dart';
import 'package:shape_up_app/enums/trainingService/muscle_group.dart';
import 'package:shape_up_app/enums/trainingService/workout_status.dart';
import 'package:shape_up_app/enums/trainingService/workout_visibility.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/valueObjects/trainingService/workout_exercise_value_object.dart';

class TrainingService {
  static final String baseUrl = dotenv.env['TRAINING_SERVICE_BASE_URL']!;

  static Map<String, String> createHeaders(String token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    return headers;
  }

  static Future<ExerciseDto> getExerciseByIdAsync(String exerciseId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Exercise/$exerciseId'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      return ExerciseDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load exercise');
    }
  }

  static Future<List<ExerciseDto>> getExercisesByMuscleGroupAsync(
    MuscleGroup? muscleGroup,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse(
        '$baseUrl/v1/Exercise${(muscleGroup != null ? '?muscleGroup=${muscleGroup.index}' : '')}',
      ),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      return ExerciseDto.fromJsonList(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  static Future<WorkoutDto> getWorkoutByIdAsync(String workoutId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Workout/$workoutId'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      return WorkoutDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load workout');
    }
  }

  static Future<List<WorkoutDto>> getWorkoutsByUserIdAsync(
    String userId,
  ) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/User/$userId/Workout'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      return WorkoutDto.fromJsonList(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load workouts');
    }
  }

  static Future<void> deleteWorkoutByIdAsync(String workoutId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/Workout/$workoutId'),
      headers: createHeaders(token),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete workout');
    }
  }

  static Future<WorkoutDto> createWorkoutAsync(
    String name,
    WorkoutVisibility visibility,
    List<String> exercises,
      int restingTimeInSeconds,
  ) async {
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      'name': name,
      'visibility': visibility.index,
      'exercises': exercises,
      'restingTimeInSeconds': restingTimeInSeconds,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/v1/Workout'),
      headers: createHeaders(token),
      body: body,
    );

    if (response.statusCode == 201) {
      return WorkoutDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create workout');
    }
  }

  static Future<WorkoutDto> createWorkoutForClientAsync(
      String clientId,
      String name,
      WorkoutVisibility visibility,
      List<String> exercises,
      int restingTimeInSeconds,
      ) async {
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      'name': name,
      'visibility': visibility.index,
      'exercises': exercises,
      'restingTimeInSeconds': restingTimeInSeconds,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/v1/User/$clientId/Workout'),
      headers: createHeaders(token),
      body: body,
    );

    if (response.statusCode == 201) {
      return WorkoutDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create workout');
    }
  }

  static Future<WorkoutDto> updateWorkoutAsync(
    String workoutId,
    String name,
    WorkoutVisibility visibility,
    List<String> exercises,
  ) async {
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      'name': name,
      'visibility': visibility.index,
      'exercises': exercises,
    });

    final response = await http.put(
      Uri.parse('$baseUrl/v1/Workout/$workoutId'),
      headers: createHeaders(token),
      body: body,
    );

    if (response.statusCode == 200) {
      return WorkoutDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update workout');
    }
  }

  static Future<WorkoutSessionDto> createWorkoutSessionAsync(String workoutId, List<WorkoutExerciseValueObject> exercises) async {
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      'workoutId': workoutId,
      'exercises': exercises.map((e) => {
        'exerciseId': e.exerciseId,
        'weight': e.weight,
        'repetitions': e.repetitions,
        'measureUnit': e.measureUnit.index
      }).toList(),
    });

    final response = await http.post(
      Uri.parse('$baseUrl/v1/WorkoutSession'),
      headers: createHeaders(token),
      body: body,
    );

    if (response.statusCode == 201) {
      return WorkoutSessionDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create workout session');
    }
  }

  static Future<List<WorkoutSessionDto>> getWorkoutSessionsByWorkoutIdAsync(String workoutId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/Workout/$workoutId/WorkoutSession'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      return WorkoutSessionDto.fromJsonList(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load workout sessions');
    }
  }

  static Future<WorkoutSessionDto> getWorkoutSessionByIdAsync(String sessionId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/WorkoutSession/$sessionId'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      return WorkoutSessionDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load workout session');
    }
  }

  static Future<WorkoutSessionDto> updateWorkoutSessionAsync(
    String sessionId,
    WorkoutStatus status,
    List<WorkoutExerciseValueObject> exercises
  ) async {
    var token = await AuthenticationService.getToken();

    final body = jsonEncode({
      'status': status.index,
      'exercises': exercises.map((e) => {
        'exerciseId': e.exerciseId,
        'weight': e.weight,
        'repetitions': e.repetitions,
        'measureUnit': e.measureUnit.index
      }).toList(),
    });

    final response = await http.put(
      Uri.parse('$baseUrl/v1/WorkoutSession/$sessionId'),
      headers: createHeaders(token),
      body: body,
    );

    if (response.statusCode == 200) {
      return WorkoutSessionDto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update workout session');
    }
  }

  static Future<void> deleteWorkoutSessionByIdAsync(String sessionId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/WorkoutSession/$sessionId'),
      headers: createHeaders(token),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete workout session');
    }
  }

  static Future<WorkoutSessionDto?> getCurrentWorkoutSessionAsync(String userId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/WorkoutSession/CurrentWorkoutSession'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      return WorkoutSessionDto.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load current workout session');
    }
  }

  static Future<List<WorkoutSessionDto>> getWorkoutSessionsByUserIdAsync(String userId) async {
    var token = await AuthenticationService.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/v1/User/$userId/WorkoutSession'),
      headers: createHeaders(token),
    );

    if (response.statusCode == 200) {
      return WorkoutSessionDto.fromJsonList(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load workout sessions');
    }
  }
}
