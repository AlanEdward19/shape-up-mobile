import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/trainingService/workout_dto.dart';
import 'package:shape_up_app/dtos/trainingService/workout_session_dto.dart';
import 'package:shape_up_app/pages/create_workout_page.dart';
import 'package:shape_up_app/pages/workout_session.dart';
import 'package:shape_up_app/services/training_service.dart';

class WorkoutDetails extends StatelessWidget {
  final WorkoutDto workout;

  const WorkoutDetails({Key? key, required this.workout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          workout.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF191F2B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateWorkoutPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirmar exclusão"),
                  content: const Text("Você tem certeza que deseja excluir este treino?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Deletar", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await TrainingService.deleteWorkoutByIdAsync(workout.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Workout deleted successfully!")),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error deleting workout: $e")),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF191F2B), // Updated background color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Text(
                "Visibilidade: ${workout.visibility}",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                "Exercícios",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workout.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = workout.exercises[index];
                        return Card(
                          color: const Color(0xFF2A2A3D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            leading: exercise.imageUrl != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                exercise.imageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                                : const Icon(Icons.image_not_supported, color: Colors.grey),
                            title: Text(
                              exercise.name,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: const Text(
                        "Execuções Anteriores",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      children: [
                        FutureBuilder<List<WorkoutSessionDto>>(
                          future: TrainingService.getWorkoutSessionsByWorkoutIdAsync(workout.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error loading sessions: ${snapshot.error}",
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No sessions found.",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              );
                            }

                            final sessions = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: sessions.length,
                              itemBuilder: (context, index) {
                                final session = sessions[index];
                                var difference = session.endedAt != null
                                    ? session.endedAt!.difference(session.startedAt)
                                    : Duration.zero;
                                return Card(
                                  color: const Color(0xFF2A2A3D),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(
                                      "${session.startedAt.day.toString().padLeft(2, '0')}/${session.startedAt.month.toString().padLeft(2, '0')}/${session.startedAt.year}",
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                    subtitle: Text(
                                      "Duração: ${difference.inMinutes.remainder(60)}m ${difference.inSeconds.remainder(60)}s\nStatus: ${session.status.toStringPtBr()}",
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var workoutSession = await TrainingService.createWorkoutSessionAsync(workout.id, []);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutSession(sessionId: workoutSession.sessionId, workout: workout),
            ),
          );
        },
        label: const Text(
          "Iniciar Treino",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(
          Icons.play_arrow,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}