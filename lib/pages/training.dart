import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/trainingService/exercise_dto.dart';
import 'package:shape_up_app/dtos/trainingService/workout_dto.dart';
import 'package:shape_up_app/enums/trainingService/workout_visibility.dart';
import 'package:shape_up_app/pages/create_workout_page.dart';
import 'package:shape_up_app/pages/exercise_selection_page.dart';
import 'package:shape_up_app/pages/workout_session.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/training_service.dart';

class Training extends StatefulWidget {
  const Training({super.key});

  @override
  State<Training> createState() => _TrainingState();
}

class _TrainingState extends State<Training>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<WorkoutDto>> _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _workoutsFuture = _fetchWorkouts();
  }

  Future<List<WorkoutDto>> _fetchWorkouts() async {
    var userId = await AuthenticationService.getProfileId();
    return await TrainingService.getWorkoutsByUserIdAsync(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treino', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF191F2B),
        bottom: TabBar(
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.white,
          controller: _tabController,
          tabs: const [Tab(text: "Meus Treinos"), Tab(text: "Meus Clientes")],
          onTap: (index) {
            if (index == 1) {
              // Desabilitar "Meus Clientes"
              _tabController.animateTo(0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Aba 'Meus Clientes' está desabilitada no momento.",
                  ),
                ),
              );
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics:
            const NeverScrollableScrollPhysics(), // Evita swipe para aba desabilitada
        children: [
          _buildMyWorkoutsSection(),
          const Center(child: Text("Meus Clientes (Desabilitado)")),
        ],
      ),
    );
  }

  Widget _buildMyWorkoutsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Treinos Criados",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  _navigateToCreateWorkoutPage(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: FutureBuilder<List<WorkoutDto>>(
              future: _workoutsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Erro ao carregar treinos: ${snapshot.error}"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nenhum treino encontrado."));
                }

                final workouts = snapshot.data!;
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(
                          workout.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          "Toque para ver detalhes",
                          style: TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          _showWorkoutDetails(context, workout);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateWorkoutPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateWorkoutPage()),
    );
  }

  void _showWorkoutDetails(BuildContext context, WorkoutDto workout) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191F2B),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                workout.name,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.green),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => WorkoutSession(workout: workout),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToEditWorkoutPage(context, workout);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      Navigator.pop(context);
                      await TrainingService.deleteWorkoutByIdAsync(workout.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Treino deletado com sucesso"),
                        ),
                      );
                      setState(() {
                        _workoutsFuture = _fetchWorkouts();
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Visibilidade: ${workout.visibility}",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                "Exercícios:",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...workout.exercises.map((exercise) {
                return ListTile(
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
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _navigateToEditWorkoutPage(BuildContext context, WorkoutDto workout) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateWorkoutPage()),
    );
  }
}
