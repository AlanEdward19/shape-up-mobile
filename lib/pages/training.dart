import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_dto.dart';
import 'package:shape_up_app/dtos/trainingService/exercise_dto.dart';
import 'package:shape_up_app/dtos/trainingService/workout_dto.dart';
import 'package:shape_up_app/dtos/trainingService/workout_session_dto.dart';
import 'package:shape_up_app/enums/trainingService/workout_visibility.dart';
import 'package:shape_up_app/pages/create_workout_page.dart';
import 'package:shape_up_app/pages/exercise_selection_page.dart';
import 'package:shape_up_app/pages/workout_details.dart';
import 'package:shape_up_app/pages/workout_session.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/professional_management_service.dart';
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
  ClientDto? clientData;
  late Future<List<WorkoutDto>> _workoutsFuture;
  late Future<WorkoutSessionDto?> _currentSessionFuture;
  List<ClientDto> clients = [];
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _loadClientData();
    _tabController = TabController(length: 2, vsync: this);
    _workoutsFuture = _fetchWorkouts();
    _currentSessionFuture = _fetchCurrentSession();
  }

  Future<void> _fetchClients() async {
    try {
      final professionalId = await AuthenticationService.getProfileId();
      final fetchedClients = await ProfessionalManagementService.getProfessionalClientsAsync(professionalId);

      setState(() {
        clients = fetchedClients;
      });
    } catch (e) {
      // Handle error
      print("Error fetching clients: $e");
    }
  }

  Future<List<WorkoutDto>> _fetchWorkouts() async {
    var userId = await AuthenticationService.getProfileId();
    return await TrainingService.getWorkoutsByUserIdAsync(userId);
  }

  Future<void> _loadClientData() async {
    try {
      final profileId = await AuthenticationService.getProfileId();
      final client = await ProfessionalManagementService.getClientByIdAsync(
        profileId,
      );

      if(client.isNutritionist || client.isTrainer){
        await _fetchClients();
      }

      setState(() {
        clientData = client;
      });
    } catch (e) {
      print('Error loading client data: $e');
    }
  }

  Future<WorkoutSessionDto?> _fetchCurrentSession() async {
    var userId = await AuthenticationService.getProfileId();
    return await TrainingService.getCurrentWorkoutSessionAsync(userId);
  }

  @override
  void didPopNext() {
    _workoutsFuture = _fetchWorkouts();
    _currentSessionFuture = _fetchCurrentSession();
    _dialogShown = false;
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkoutSessionDto?>(
      future: _currentSessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null && !_dialogShown) {
          _dialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSessionInProgressDialog(context, snapshot.data!);
          });
          return const SizedBox();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Treino', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: const Color(0xFF191F2B),
            bottom: clientData != null && (clientData!.isNutritionist || clientData!.isTrainer) ? TabBar(
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.white,
              controller: _tabController,
              tabs: [Tab(text: "Meus Treinos"), if(clientData!.isNutritionist || clientData!.isTrainer) Tab(text: "Meus Clientes")],
            ) : null,
          ),
          body: clientData != null && (clientData!.isNutritionist || clientData!.isTrainer) ? TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMyWorkoutsSection(),
              if (clientData!.isNutritionist || clientData!.isTrainer)
                _buildClientsWorkoutsSection(),
            ],
          ) : _buildMyWorkoutsSection(),
        );
      },
    );
  }

  void _showSessionInProgressDialog(BuildContext context, WorkoutSessionDto session) {
    showDialog(
      context: context,
      barrierDismissible: false, // Impede o fechamento ao clicar fora do diálogo
      builder: (context) {
        return AlertDialog(
          title: const Text("Sessão em andamento"),
          content: const Text(
            "Você ainda tem uma sessão em andamento. Deseja apagá-la ou continuar?",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await TrainingService.deleteWorkoutSessionByIdAsync(session.sessionId);
                setState(() {
                  _currentSessionFuture = _fetchCurrentSession();
                });
                Navigator.of(context).pop(); // Fecha o diálogo após atualizar o estado
              },
              child: const Text("Apagar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o diálogo antes de navegar

                WorkoutDto workout = await _workoutsFuture.then((workouts) => workouts.firstWhere(
                      (w) => w.id == session.workoutId,
                ));

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutSession(
                      sessionId: session.sessionId,
                      workout: workout,
                      startedAt: session.startedAt,
                    ),
                  ),
                );
              },
              child: const Text("Continuar"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClientsWorkoutsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            const Text(
              "Treinos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _navigateToCreateWorkoutPage(context, true);
            },
          ),]),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                return Card(
                  color: const Color(0xFF2A2A3D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(
                      client.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: const Text(
                      "Toque para ver treinos",
                      style: TextStyle(color: Colors.white70),
                    ),
                    children: [
                      FutureBuilder<List<WorkoutDto>>(
                        future: TrainingService.getWorkoutsByUserIdAsync(client.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Erro ao carregar treinos: ${snapshot.error}",
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Nenhum treino encontrado.",
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }

                          var workouts = snapshot.data!;
                          workouts = workouts.where((workout) => workout.creatorId == clientData!.id).toList();
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5), // Padding entre os treinos e a seção
                            child: SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: workouts.length,
                                itemBuilder: (context, index) {
                                  final workout = workouts[index];
                                  return Container(
                                    width: 200,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
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
                                        _showWorkoutDetails(context, workout, true, client.id);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
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
                "Meus Treinos",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  _navigateToCreateWorkoutPage(context, false);
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
                  return const Center(child: Text("Nenhum treino encontrado.", style: TextStyle(color: Colors.white),));
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
                        color: workout.creatorId == clientData!.id ? Colors.blue : Colors.black38,
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
                          _showWorkoutDetails(context, workout, false, '');
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

  void _navigateToCreateWorkoutPage(BuildContext context, bool isClientWorkout) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateWorkoutPage(isClientWorkout:isClientWorkout)),
    );
  }

  void _showWorkoutDetails(BuildContext context, WorkoutDto workout, bool isClient, String clientId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetails(workout: workout, isClientTraining: isClient,clientId: clientId, loggedUserId: clientData!.id,),
      ),
    );
  }
}
