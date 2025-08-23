import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/trainingService/exercise_dto.dart';
import 'package:shape_up_app/enums/trainingService/workout_visibility.dart';
import 'package:shape_up_app/pages/exercise_selection_page.dart';
import 'package:shape_up_app/services/training_service.dart';

class EditWorkoutPage extends StatefulWidget {
  final String workoutId;

  const EditWorkoutPage({Key? key, required this.workoutId}) : super(key: key);

  @override
  _EditWorkoutPageState createState() => _EditWorkoutPageState();
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  late TextEditingController workoutNameController;
  WorkoutVisibility selectedVisibility = WorkoutVisibility.private;
  List<ExerciseDto> selectedExercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    workoutNameController = TextEditingController();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    try {
      final workout = await TrainingService.getWorkoutByIdAsync(widget.workoutId);
      setState(() {
        workoutNameController.text = workout.name;
        selectedVisibility = workout.visibility;
        selectedExercises = workout.exercises;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load workout: $e')),
      );
    }
  }

  @override
  void dispose() {
    workoutNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Editar Treino"),
          backgroundColor: const Color(0xFF191F2B),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar Treino",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF191F2B),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              try {
                await TrainingService.updateWorkoutAsync(
                  widget.workoutId,
                  workoutNameController.text,
                  selectedVisibility,
                  selectedExercises.map((e) => e.id).toList(),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update workout: $e')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nome do Treino",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: workoutNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Digite o nome do treino",
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Exercícios",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () async {
                    final exercises = await Navigator.push<List<ExerciseDto>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseSelectionPage(),
                      ),
                    );

                    if (exercises != null) {
                      setState(() {
                        selectedExercises.addAll(exercises);
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: selectedExercises.length,
                itemBuilder: (context, index) {
                  final exercise = selectedExercises[index];
                  return Card(
                    color: Colors.white10,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: exercise.imageUrl != null
                          ? Image.network(
                        exercise.imageUrl!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                          : const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                      title: Text(
                        exercise.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            selectedExercises.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}