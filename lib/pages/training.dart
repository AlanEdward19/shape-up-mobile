import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/trainingService/exercise_dto.dart';
import 'package:shape_up_app/enums/trainingService/workout_visibility.dart';
import 'package:shape_up_app/pages/create_workout_page.dart';
import 'package:shape_up_app/pages/exercise_selection_page.dart';

class Training extends StatefulWidget {
  const Training({super.key});

  @override
  State<Training> createState() => _TrainingState();
}

class _TrainingState extends State<Training> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          tabs: const [
            Tab(text: "Meus Treinos"),
            Tab(text: "Meus Clientes"),
          ],
          onTap: (index) {
            if (index == 1) {
              // Desabilitar "Meus Clientes"
              _tabController.animateTo(0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Aba 'Meus Clientes' está desabilitada no momento.")),
              );
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Evita swipe para aba desabilitada
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    title: Text(
                      "Treino ${index + 1}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      "Detalhes do treino",
                      style: TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      // Lógica para visualizar treino
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Visualizar Treino ${index + 1}")),
                      );
                    },
                  ),
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
      MaterialPageRoute(
        builder: (context) => CreateWorkoutPage(),
      ),
    );
  }
}