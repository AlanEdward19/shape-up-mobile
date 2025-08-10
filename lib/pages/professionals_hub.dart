import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_score_dto.dart';
import 'package:shape_up_app/enums/professionalManagementService/professional_type.dart';
import 'package:shape_up_app/pages/professional_profile.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/professional_management_service.dart';
import 'package:shape_up_app/services/social_service.dart';

class ProfessionalsHub extends StatefulWidget {
  @override
  _ProfessionalsHubState createState() => _ProfessionalsHubState();
}

class _ProfessionalsHubState extends State<ProfessionalsHub> {
  ClientDto? clientData;
  List<ProfessionalDto> recommendedProfessionals = [];
  List<ProfessionalScoreDto> recommendedProfessionalsScore = [];
  bool isLoading = true;
  bool isLoadingRecommended = true;

  @override
  void initState() {
    super.initState();
    _loadClientData();
    _loadRecommendedProfessionals();
  }

  Future<void> _loadRecommendedProfessionals() async {
    try {
      final professionals =
          await ProfessionalManagementService.getProfessionalsAsync();

      final List<ProfessionalScoreDto> professionalsScore = professionals.isNotEmpty ? await Future.wait(
        professionals.map((professional) async {
          return await ProfessionalManagementService.getProfessionalScoreByIdAsync(
            professional.id,
          );
        }),
      ) : [];

      setState(() {
        recommendedProfessionals = professionals;
        recommendedProfessionalsScore = professionalsScore;
        isLoadingRecommended = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRecommended = false;
      });
      print('Error loading recommended professionals: $e');
    }
  }

  Future<void> _loadClientData() async {
    try {
      final profileId = await AuthenticationService.getProfileId();
      final client = await ProfessionalManagementService.getClientByIdAsync(
        profileId,
      );
      setState(() {
        clientData = client;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error (e.g., show a snackbar or log the error)
      print('Error loading client data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profissionais',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF191F2B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading || isLoadingRecommended
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar profissionais...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        fillColor: Colors.white24,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onChanged: (value) {
                        // Implementar lógica de busca
                      },
                    ),
                  ),

                  // Active Plans Section
                  Expanded(
                    child: ListView(
                      children: [
                        _buildSectionTitle('Planos Ativos'),
                        _buildActivePlansList(),

                        _buildSectionTitle('Profissionais Recomendados'),
                        _buildRecommendedProfessionalsList(context),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActivePlansList() {
    var dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      children:
          clientData!.servicePlans.map((plan) {
            return Card(
              margin: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 16.0,
              ),
              child: ListTile(
                title: Text(plan.servicePlan.title),
                subtitle: Text(
                  '${dateFormat.format(plan.startDate)} até ${dateFormat.format(plan.endDate)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        _showDeleteServicePlanDialog(plan.servicePlan.id);
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        _showReviewDialog(plan.servicePlan.professionalId, plan.servicePlan.id);
                      },
                      child: const Text('Avaliar'),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildRecommendedProfessionalsList(BuildContext context) {

    return SizedBox(
      height: 175,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            recommendedProfessionals.map((professional) {
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              professional.name!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(switch (professional.type) {
                              ProfessionalType.Nutritionist => 'Nutricionista',
                              ProfessionalType.Trainer => 'Personal Trainer',
                              ProfessionalType.Both =>
                                'Nutricionista e Personal Trainer',
                            }),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                Text(
                                  recommendedProfessionalsScore
                                      .firstWhere((score) => score.professionalId == professional.id,
                                    orElse: () => ProfessionalScoreDto('', 0, 0, DateTime.now()))
                                      .averageScore
                                      .toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProfessionalProfile(professional: professional, professionalScore: recommendedProfessionalsScore.firstWhere((score) => score.professionalId == professional.id, orElse: () => ProfessionalScoreDto('', 0, 0, DateTime.now())), loggedInUser: clientData!),
                                  ),
                                );
                              },
                              child: const Text('Ver Perfil'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  void _showReviewDialog(String professionalId, String servicePlanId) {
    final TextEditingController commentController =
    TextEditingController();
    int updatedRating = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Avaliar profissional'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nota:'),
                  DropdownButton<int>(
                    value: updatedRating,
                    items: List.generate(5, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        updatedRating = value;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comentário',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {

                  await ProfessionalManagementService.createProfessionalReviewAsync(
                    professionalId,
                    servicePlanId,
                    commentController.text,
                    updatedRating,
                  );

                  await _loadRecommendedProfessionals();

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Profissional avaliado com sucesso!',
                      ),
                    ),
                  );
                } catch (e) {
                  print('Erro ao avaliar professional: $e');
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteServicePlanDialog(String servicePlanId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja cancelar esse plano de serviço?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ProfessionalManagementService.deleteServicePlanFromClientAsync(clientData!.id, servicePlanId);

                  await _loadClientData();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Plano de serviço cancelado com sucesso!'),
                    ),
                  );
                } catch (e) {
                  print('Erro ao cancelar plano de serviço: $e');
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}
