import 'package:shape_up_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shape_up_app/pages/edit_workout_page.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shape_up_app/dtos/trainingService/workout_dto.dart';
import 'package:shape_up_app/dtos/trainingService/workout_session_dto.dart';
import 'package:shape_up_app/pages/create_workout_page.dart';
import 'package:shape_up_app/services/training_service.dart';

import 'workout_session.dart';

class WorkoutDetails extends StatefulWidget {
  final WorkoutDto workout;

  const WorkoutDetails({Key? key, required this.workout}) : super(key: key);

  @override
  _WorkoutDetailsState createState() => _WorkoutDetailsState();
}

class _WorkoutDetailsState extends State<WorkoutDetails>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  String? highlightMuscleGroupsSvg;

  void updateSvg() async {
    var svgBase = await rootBundle.loadString('assets/icons/FrontViewMuscleMap.svg');
    var muscleGroupIds = widget.workout.exercises
        .expand((e) => e.muscleGroups)
        .map((mg) => mg.toString())
        .toSet();

    setState(() {
      highlightMuscleGroupsSvg = paintSvgByIds(svgBase, ids: muscleGroupIds);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    updateSvg();
  }

  void updateWorkout() async {
    try {
      var updatedWorkout = await TrainingService.getWorkoutByIdAsync(widget.workout.id);
      setState(() {
        widget.workout.name = updatedWorkout.name;
        widget.workout.visibility = updatedWorkout.visibility;
        widget.workout.exercises = updatedWorkout.exercises;
      });
      updateSvg(); // Atualiza o SVG com os novos dados
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating workout: $e")),
      );
    }
  }

  @override
  void didPopNext() {
    updateSvg();
    updateWorkout();
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.workout.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF191F2B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 100),
          // Row 1: SVG
          Center(
            child: SvgPicture.string(highlightMuscleGroupsSvg!, height: 300),
          ),
          const SizedBox(height: 16),

          // Row 2: Iniciar treino
          Center(
            child: FloatingActionButton.extended(
              onPressed: () async {
                var workoutSession =
                    await TrainingService.createWorkoutSessionAsync(
                      widget.workout.id,
                      [],
                    );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => WorkoutSession(
                          sessionId: workoutSession.sessionId,
                          workout: widget.workout,
                        ),
                  ),
                );
              },
              label: const Text(
                "Iniciar Treino",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              backgroundColor: Colors.blueAccent,
              elevation: 4,
            ),
          ),
          const SizedBox(height: 24),

          // Row 3: Editar e Deletar treino
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditWorkoutPage(
                        workoutId: widget.workout.id,
                      ),
                    ),
                  ).then((_) => setState(() {
                    updateSvg();
                  }));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Editar Treino',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Confirmar exclusão"),
                          content: const Text(
                            "Você tem certeza que deseja excluir este treino?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "Deletar",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true) {
                    try {
                      await TrainingService.deleteWorkoutByIdAsync(
                        widget.workout.id,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Workout deleted successfully!"),
                        ),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error deleting workout: $e")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Deletar Treino',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tabs: Exercícios e Execuções anteriores
          TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            controller: _tabController,
            tabs: const [
              Tab(text: 'Exercícios'),
              Tab(text: 'Execuções anteriores'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Conteúdo da aba "Exercícios"
                Center(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.workout.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = widget.workout.exercises[index];
                      return Card(
                        color: const Color(0xFF2A2A3D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        child: ListTile(
                          leading:
                              exercise.imageUrl != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      exercise.imageUrl!,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                          title: Text(
                            exercise.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Conteúdo da aba "Execuções anteriores"
                Center(
                  child: FutureBuilder<List<WorkoutSessionDto>>(
                    future: TrainingService.getWorkoutSessionsByWorkoutIdAsync(
                      widget.workout.id,
                    ),
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
                        padding: const EdgeInsets.all(16),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          var difference =
                              session.endedAt != null
                                  ? session.endedAt!.difference(
                                    session.startedAt,
                                  )
                                  : Duration.zero;
                          return Card(
                            color: const Color(0xFF2A2A3D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            child: ListTile(
                              title: Text(
                                "${session.startedAt.day.toString().padLeft(2, '0')}/${session.startedAt.month.toString().padLeft(2, '0')}/${session.startedAt.year}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String paintSvgByIds(
      String rawSvg, {
        required Iterable<String> ids,
        Color color = const Color(0xFF2196F3),
      }) {
    String hex(Color c) =>
        '#${c.red.toRadixString(16).padLeft(2, '0')}${c.green.toRadixString(16).padLeft(2, '0')}${c.blue.toRadixString(16).padLeft(2, '0')}';

    void applyFill(xml.XmlElement e) {
      // remove "fill:" de style inline, se houver
      final style = e.getAttribute('style');
      if (style != null) {
        final cleaned = style.replaceAll(RegExp(r'fill\s*:\s*[^;]+;?'), '');
        cleaned.trim().isEmpty
            ? e.removeAttribute('style')
            : e.setAttribute('style', cleaned);
      }
      // seta o fill diretamente
      e.setAttribute('fill', hex(color));
    }

    final doc = xml.XmlDocument.parse(rawSvg);
    final wanted = ids.toSet();

    final byId = <String, xml.XmlElement>{};
    for (final el in doc.descendants.whereType<xml.XmlElement>()) {
      final id = el.getAttribute('id');
      if (id != null) byId[id] = el;
    }

    for (final id in wanted) {
      final el = byId[id];
      if (el == null) continue;

      applyFill(el);

      // se for um grupo, pinta também os descendentes desenháveis
      for (final child in el.descendants.whereType<xml.XmlElement>()) {
        final name = child.name.local;
        if (name == 'path') {
          applyFill(child);
        }
      }
    }

    return doc.toXmlString();
  }
}
