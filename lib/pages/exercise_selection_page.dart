import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/trainingService/exercise_dto.dart';
import 'package:shape_up_app/enums/trainingService/muscle_group.dart';
import 'package:shape_up_app/widgets/trainingService/circular_image.dart';

import '../services/training_service.dart' show TrainingService;

class ExerciseSelectionPage extends StatefulWidget {
  @override
  _ExerciseSelectionPageState createState() => _ExerciseSelectionPageState();
}

class _ExerciseSelectionPageState extends State<ExerciseSelectionPage> {
  List<ExerciseDto> allExercises = [];
  List<ExerciseDto> filteredExercises = [];
  List<ExerciseDto> selectedExercises = [];
  MuscleGroup? selectedFilter;
  List<MuscleGroup> selectedFilters = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final exercises = await TrainingService.getExercisesByMuscleGroupAsync(null);
    setState(() {
      allExercises = exercises;
      filteredExercises = exercises;
    });
  }

  void _filterExercises(String query) {
    setState(() {
      filteredExercises = allExercises
          .where((exercise) =>
      exercise.name.toLowerCase().contains(query.toLowerCase()) &&
          (selectedFilter == null || exercise.muscleGroups.contains(selectedFilter)))
          .toList();
    });
  }

  void _applyFilter(List<MuscleGroup> filters) {
    setState(() {
      selectedFilter = null;
      List<MuscleGroup> selectedFilters = filters.expand((filter) {
        return [filter, ...getRelatedMuscleGroups(filter)];
      }).toList();

      filteredExercises = allExercises.where((exercise) {
        return selectedFilters.isEmpty || selectedFilters.any((filter) => exercise.muscleGroups.contains(filter));
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Exercícios', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF191F2B),
        actions: [
      IconButton(
      icon: const Icon(Icons.filter_list),
      onPressed: _showMuscleGroupFilterDialog,
    ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Pesquisar Exercício",
                prefixIcon: Icon(Icons.search, color: Colors.white),
                labelStyle: TextStyle(color: Colors.white),
              ),
              onChanged: _filterExercises,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = filteredExercises[index];
                final isSelected = selectedExercises.contains(exercise);
                return ListTile(
                  leading: CircularImage(
                    imageUrl: exercise.imageUrl,
                    size: 50,
                    borderColor: Colors.white10,
                    borderWidth: 2,
                  ),
                  title: Text(
                    exercise.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedExercises.remove(exercise);
                      } else {
                        selectedExercises.add(exercise);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, selectedExercises);
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  void _showMuscleGroupFilterDialog() async {
    final mainMuscleGroups = getMainMuscleGroups();
    final secondaryMuscleGroups = getSecondaryMuscleGroups();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Filtrar por Grupo Muscular"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filtro por Agrupamento Muscular",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: mainMuscleGroups.map((group) {
                        final isSelected = selectedFilters.contains(group);
                        return FilterChip(
                          label: Text(group.toStringPtBr()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedFilters.add(group);
                              } else {
                                selectedFilters.remove(group);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Filtro por Músculo",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: secondaryMuscleGroups.map((group) {
                        final isSelected = selectedFilters.contains(group);
                        return FilterChip(
                          label: Text(group.toStringPtBr()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedFilters.add(group);
                              } else {
                                selectedFilters.remove(group);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilters.clear();
                    });
                  },
                  child: const Text("Limpar"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, selectedFilters);
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      },
    ).then((filters) {
      if (filters != null) {
        _applyFilter(filters);
      }
    });
  }
}