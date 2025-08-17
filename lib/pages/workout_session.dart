import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/trainingService/workout_dto.dart';
import 'package:shape_up_app/enums/trainingService/measure_unit.dart';
import 'package:shape_up_app/enums/trainingService/workout_status.dart';
import 'package:shape_up_app/services/training_service.dart';
import 'package:shape_up_app/valueObjects/trainingService/workout_exercise_value_object.dart';

class WorkoutSession extends StatefulWidget {
  final String sessionId;
  final WorkoutDto workout;

  const WorkoutSession({super.key, required this.sessionId,required this.workout});

  @override
  State<WorkoutSession> createState() => _WorkoutSessionState();
}

class _WorkoutSessionState extends State<WorkoutSession> {
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;
  Map<String, bool> _expandedCards = {};
  Map<String, List<Map<String, dynamic>>> _exerciseSeries = {};

  @override
  void initState() {
    super.initState();

    for (var exercise in widget.workout.exercises) {
      _expandedCards[exercise.id] = false;
      _exerciseSeries[exercise.id] = [];
      _exerciseSeries[exercise.id]!.add({'weight': null, 'reps': null, 'completed': false});
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime += const Duration(seconds: 1);
      });
    });
  }

  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          await TrainingService.deleteWorkoutSessionByIdAsync(widget.sessionId);
      return true;
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.workout.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF191F2B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.blue),
            onPressed: () async {
              try {

                final exercises = widget.workout.exercises.map((exercise) {
                  final series = _exerciseSeries[exercise.id]!;
                  return series.map((s) {
                    return WorkoutExerciseValueObject(
                      exerciseId: exercise.id,
                      weight: s['weight'],
                      repetitions: s['reps'],
                      measureUnit: MeasureUnit.kilogram,
                    );
                  }).toList();
                }).expand((e) => e).toList();

                await TrainingService.updateWorkoutSessionAsync(widget.sessionId, WorkoutStatus.finished, exercises);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Treino finalizado com sucesso!")),
                );
                Navigator.pop(context);
              } catch (e) {
                // Handle errors
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erro ao finalizar treino: $e")),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Timer
            Center(
              child: Text(
                _formatDuration(_elapsedTime),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // List of exercises
            Expanded(
              child: ListView.builder(
                itemCount: widget.workout.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = widget.workout.exercises[index];
                  final isExpanded = _expandedCards[exercise.id] ?? false;

                  return Card(
                    color: Colors.white10,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          leading: exercise.imageUrl != null
                              ? Image.network(
                            exercise.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.image_not_supported, color: Colors.grey),
                          title: Text(
                            exercise.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            setState(() {
                              _expandedCards[exercise.id] = !isExpanded;
                            });
                          },
                        ),
                        if (isExpanded)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                // List of series
                                ..._exerciseSeries[exercise.id]!.asMap().entries.map((entry) {
                                  final seriesIndex = entry.key;
                                  final series = entry.value;

                                  return Dismissible(
                                    key: Key('${exercise.id}_$seriesIndex'),
                                    direction: DismissDirection.startToEnd,
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: const Icon(Icons.delete, color: Colors.white),
                                    ),
                                    onDismissed: (direction) {
                                      setState(() {
                                        _exerciseSeries[exercise.id]!.removeAt(seriesIndex);
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Série ${seriesIndex + 1} removida!')),
                                      );
                                    },
                                    child: Container(
                                      color: series['complete'] == true ? Colors.white12 : Colors.white10,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              decoration: const InputDecoration(
                                                labelText: "Peso",
                                                labelStyle: TextStyle(color: Colors.white70),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.white70),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blue),
                                                ),
                                              ),
                                              keyboardType: TextInputType.number,
                                              style: const TextStyle(color: Colors.white),
                                              onChanged: (value) {
                                                series['weight'] = int.tryParse(value);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextField(
                                              decoration: const InputDecoration(
                                                labelText: "Reps",
                                                labelStyle: TextStyle(color: Colors.white70),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.white70),
                                                ),
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.blue),
                                                ),
                                              ),
                                              keyboardType: TextInputType.number,
                                              style: const TextStyle(color: Colors.white),
                                              onChanged: (value) {
                                                series['reps'] = int.tryParse(value);
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon: const Icon(Icons.check, color: Colors.green),
                                            onPressed: () {
                                              setState(() {
                                                if (series['weight'] == null || series['reps'] == null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Preencha peso e repetições antes de marcar como completa.")),
                                                  );
                                                  return;
                                                }
                                                else if(series['weight']! <= 0 || series['reps']! <= 0){
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text("Peso e repetições devem ser maiores que zero.")),
                                                  );
                                                  return;
                                                }
                                                else if(series['complete'] == null || series['complete'] == false)
                                                  series['complete'] = true;
                                                else
                                                  series['complete'] = false;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                const SizedBox(height: 8),
                                // Add Series Button
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _exerciseSeries[exercise.id]!.add({'weight': null, 'reps': null});
                                    });
                                  },
                                  icon: const Icon(Icons.add, color: Colors.blue),
                                  label: const Text(
                                    "Adicionar Série",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}