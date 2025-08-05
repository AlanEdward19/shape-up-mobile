import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_dto.dart';
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

      setState(() {
        recommendedProfessionals = professionals;
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
                        // Implementar lógica de cancelar
                      },
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Implementar lógica de avaliar
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
    // Exemplo de lista de profissionais recomendados

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
                                Text('5'),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ProfessionalProfile(
                                          professionalName: 'Dr. João Silva',
                                          professionalImage:
                                              'https://via.placeholder.com/150',
                                        ),
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
}
