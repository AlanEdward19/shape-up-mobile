import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_dto.dart';
import 'package:shape_up_app/dtos/trainingService/exercise_dto.dart';
import 'package:shape_up_app/enums/trainingService/workout_visibility.dart';
import 'package:shape_up_app/pages/exercise_selection_page.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/professional_management_service.dart';
import 'package:shape_up_app/services/training_service.dart';

class CreateWorkoutPage extends StatefulWidget {
  final bool isClientWorkout;

  CreateWorkoutPage({required this.isClientWorkout});

  @override
  _CreateWorkoutPageState createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  String workoutName = '';
  WorkoutVisibility selectedVisibility = WorkoutVisibility.private;
  List<ExerciseDto> selectedExercises = [];
  List<ClientDto> clients = [];
  ClientDto? selectedClient;
  int restMinutes = 0;
  int restSeconds = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isClientWorkout) {
      _fetchClients();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Criar Novo Treino",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF101827),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              var restingTimeInSeconds = Duration(minutes: restMinutes, seconds: restSeconds).inSeconds;

              if(workoutName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Por favor, insira o nome do treino.")),
                );
                return;
              }

              if(selectedExercises.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Por favor, adicione pelo menos um exercício.")),
                );
                return;
              }

              if(restingTimeInSeconds <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Por favor, insira um intervalo de descanso válido.")),
                );
                return;
              }

              if(widget.isClientWorkout){

                if(selectedClient == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, selecione um cliente.")),
                  );
                  return;
                }

                await TrainingService.createWorkoutForClientAsync(selectedClient!.id,workoutName, selectedVisibility, selectedExercises.map( (e) => e.id).toList(), restingTimeInSeconds);
              }
                else
              {
                await TrainingService.createWorkoutAsync(workoutName, selectedVisibility, selectedExercises.map( (e) => e.id).toList(), restingTimeInSeconds);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título "Nome do Treino"
            const Text(
              "Nome do Treino",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // TextField para o nome do treino
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Digite o nome do treino",
              ),
              onChanged: (value) {
                setState(() {
                  workoutName = value;
                });
              },
            ),
            if (widget.isClientWorkout) ...[
              const SizedBox(height: 24),
              const Text(
                "Selecione o Cliente",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<ClientDto>(
                value: selectedClient,
                dropdownColor: const Color(0xFF101827),
                items: clients.map((client) {
                  return DropdownMenuItem<ClientDto>(
                    value: client,
                    child: Text(
                      client.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClient = value;
                  });
                },
                hint: const Text(
                  "Selecione um cliente",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              "Intervalo de descanso",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Dropdown for minutes
                Expanded(
                  child: DropdownButton<int>(
                    value: restMinutes,
                    dropdownColor: const Color(0xFF101827),
                    items: List.generate(60, (index) => index).map((minute) {
                      return DropdownMenuItem<int>(
                        value: minute,
                        child: Text(
                          "$minute min",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        restMinutes = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Dropdown for seconds
                Expanded(
                  child: DropdownButton<int>(
                    value: restSeconds,
                    dropdownColor: const Color(0xFF101827),
                    items: List.generate(60, (index) => index).map((second) {
                      return DropdownMenuItem<int>(
                        value: second,
                        child: Text(
                          "$second sec",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        restSeconds = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Título "Exercícios" com ícone "+"
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
            // Lista de exercícios selecionados
            Expanded(
              child: ListView.builder(
                itemCount: selectedExercises.length,
                itemBuilder: (context, index) {
                  final exercise = selectedExercises[index];
                  return Card(
                    color: Colors.white10,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
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
                                size: 50,
                                color: Colors.grey,
                              ),
                      title: Text(
                        exercise.name,
                        style: TextStyle(color: Colors.white),
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
