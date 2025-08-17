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

  const WorkoutSession({
    super.key,
    required this.sessionId,
    required this.workout,
  });

  @override
  State<WorkoutSession> createState() => _WorkoutSessionState();
}

class _WorkoutSessionState extends State<WorkoutSession> {
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;

  Timer? _restTimer;
  Duration _restTime = Duration.zero;
  bool _isRestTimerRunning = false;

  Map<String, bool> _expandedCards = {};
  Map<String, List<Map<String, dynamic>>> _exerciseSeries = {};

  @override
  void initState() {
    super.initState();

    for (var exercise in widget.workout.exercises) {
      _expandedCards[exercise.id] = false;
      _exerciseSeries[exercise.id] = [];
      _exerciseSeries[exercise.id]!.add({
        'weight': null,
        'reps': null,
        'completed': false,
      });
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime += const Duration(seconds: 1);
      });
    });
  }

  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer() {
    if (_restTime.inSeconds > 0) {
      setState(() {
        _isRestTimerRunning = true;
      });
      _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_restTime.inSeconds > 0) {
            _restTime -= const Duration(seconds: 1);
          } else {
            _restTimer?.cancel();
            _isRestTimerRunning = false;
          }
        });
      });
    }
  }

  void _showRestPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Rest Timer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${_restTime.inMinutes.toString().padLeft(2, '0')}:${_restTime.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _restTime = _restTime - const Duration(seconds: 15);
                        if (_restTime.isNegative) _restTime = Duration.zero;
                      });
                    },
                    child: const Text("-15"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _restTime += const Duration(seconds: 15);
                      });
                    },
                    child: const Text("+15"),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startRestTimer();
              },
              child: const Text("Start"),
            ),
          ],
        );
      },
    );
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
                  if (_exerciseSeries.values.any(
                    (seriesList) => seriesList.any(
                      (s) => s['completed'] == null || s['completed'] == false,
                    ),
                  )) {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text("Atenção"),
                            content: const Text(
                              "Todas as séries devem ser marcadas como completas antes de finalizar o treino.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                    );
                  } else {
                    final exercises =
                        widget.workout.exercises
                            .map((exercise) {
                              final series = _exerciseSeries[exercise.id]!;
                              return series.map((s) {
                                return WorkoutExerciseValueObject(
                                  exerciseId: exercise.id,
                                  weight: s['weight'],
                                  repetitions: s['reps'],
                                  measureUnit: MeasureUnit.kilogram,
                                );
                              }).toList();
                            })
                            .expand((e) => e)
                            .toList();

                    await TrainingService.updateWorkoutSessionAsync(
                      widget.sessionId,
                      WorkoutStatus.finished,
                      exercises,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Treino finalizado com sucesso!"),
                      ),
                    );
                    Navigator.pop(context);
                  }
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
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isRestTimerRunning || _restTime.inSeconds > 0)
                    Text(
                      "${_restTime.inMinutes.toString().padLeft(2, '0')}:${_restTime.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (_isRestTimerRunning || _restTime.inSeconds > 0)
                    const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.access_time, size: 32, color: Colors.white,),
                    onPressed: _showRestPopup,
                  ),
                  const Text("Descanso", style: TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),

              const SizedBox(height: 10),

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
                            leading:
                                exercise.imageUrl != null
                                    ? Image.network(
                                      exercise.imageUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Expanded(
                                        child: Text(
                                          "Peso",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Reps",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 48,
                                      ), // Space for the check button
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // List of Series
                                  Column(
                                    children:
                                        _exerciseSeries[exercise.id]!.asMap().entries.map((
                                          entry,
                                        ) {
                                          final series = entry.value;
                                          final seriesIndex = entry.key;

                                          return Dismissible(
                                            key: Key(
                                              '${exercise.id}_$seriesIndex',
                                            ),
                                            direction:
                                                DismissDirection.startToEnd,
                                            background: Container(
                                              color: Colors.red,
                                              alignment: Alignment.centerRight,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                  ),
                                              child: const Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              ),
                                            ),
                                            onDismissed: (direction) {
                                              setState(() {
                                                _exerciseSeries[exercise.id]!
                                                    .removeAt(seriesIndex);
                                              });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Série ${seriesIndex + 1} removida!',
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    series['completed'] == true
                                                        ? Colors.blue
                                                        : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Card(
                                                      color:
                                                          series['completed'] ==
                                                                  true
                                                              ? Colors.blue
                                                              : Colors.white10,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      elevation: 0,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                            ),
                                                        child: TextField(
                                                          decoration:
                                                              const InputDecoration(
                                                                hintText:
                                                                    "Peso",
                                                                hintStyle:
                                                                    TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white70,
                                                                    ),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                          onChanged: (value) {
                                                            series['weight'] =
                                                                int.tryParse(
                                                                  value,
                                                                );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Card(
                                                      color:
                                                          series['completed'] ==
                                                                  true
                                                              ? Colors.blue
                                                              : Colors.white10,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      elevation: 0,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                            ),
                                                        child: TextField(
                                                          decoration:
                                                              const InputDecoration(
                                                                hintText:
                                                                    "Reps",
                                                                hintStyle:
                                                                    TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white70,
                                                                    ),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                          textAlign:
                                                              TextAlign.center,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          style:
                                                              const TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                          onChanged: (value) {
                                                            series['reps'] =
                                                                int.tryParse(
                                                                  value,
                                                                );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.check_circle,
                                                      color:
                                                          series['completed'] ==
                                                                  true
                                                              ? Colors.white
                                                              : Colors.grey,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (series['weight'] ==
                                                                null ||
                                                            series['reps'] ==
                                                                null) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                "Preencha peso e repetições antes de marcar como completa.",
                                                              ),
                                                            ),
                                                          );
                                                          return;
                                                        } else if (series['weight']! <=
                                                                0 ||
                                                            series['reps']! <=
                                                                0) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                "Peso e repetições devem ser maiores que zero.",
                                                              ),
                                                            ),
                                                          );
                                                          return;
                                                        } else if (series['completed'] ==
                                                                null ||
                                                            series['completed'] ==
                                                                false) {
                                                          series['completed'] =
                                                              true;
                                                        } else {
                                                          series['completed'] =
                                                              false;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                  const SizedBox(height: 8),
                                  // Add Series Button
                                  Center(
                                    child: TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _exerciseSeries[exercise.id]!.add({
                                            'weight': null,
                                            'reps': null,
                                            'completed': false,
                                          });
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.blue,
                                      ),
                                      label: const Text(
                                        "Adicionar Série",
                                        style: TextStyle(color: Colors.blue),
                                      ),
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
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
