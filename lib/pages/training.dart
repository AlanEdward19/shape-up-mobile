import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/trainingService/exercise_dto.dart';
import 'package:shape_up_app/dtos/trainingService/workout_dto.dart';
import 'package:shape_up_app/enums/trainingService/workout_visibility.dart';
import 'package:shape_up_app/pages/create_workout_page.dart';
import 'package:shape_up_app/pages/exercise_selection_page.dart';
import 'package:shape_up_app/pages/workout_details.dart';
import 'package:shape_up_app/pages/workout_session.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/training_service.dart';

import '../main.dart';

class Training extends StatefulWidget {
  const Training({super.key});

  @override
  State<Training> createState() => _TrainingState();
}

class _TrainingState extends State<Training>
    with SingleTickerProviderStateMixin, RouteAware {
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
  void didPopNext() {
    _workoutsFuture = _fetchWorkouts();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute<dynamic>);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController.dispose();
    super.dispose();
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetails(workout: workout),
      ),
    );
  }

  void _navigateToEditWorkoutPage(BuildContext context, WorkoutDto workout) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateWorkoutPage()),
    );
  }
}
