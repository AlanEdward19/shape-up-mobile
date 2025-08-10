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
  ProfessionalDto? professionalData;
  List<ClientDto> professionalClients = [];
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

      ProfessionalDto? professional;
      List<ClientDto> clients = [];

      if(client.isNutritionist || client.isTrainer)
      {
        professional = await ProfessionalManagementService.getProfessionalByIdAsync(client.id);
        clients = await ProfessionalManagementService.getProfessionalClientsAsync(professional.id);
      }

      setState(() {
        clientData = client;
        professionalData = professional;
        professionalClients = clients;
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

                        _buildProfessionalClientsAndServices(),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildProfessionalClientsAndServices() {
    if (clientData == null || (!clientData!.isTrainer && !clientData!.isNutritionist)) {
      return const SizedBox.shrink(); // Return empty if not a trainer or nutritionist
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Services Section
        _buildSectionTitle('Serviços Oferecidos'),
        if (professionalData == null || professionalData!.servicePlans.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Nenhum serviço oferecido no momento.',
              style: TextStyle(fontSize: 16, color: Colors.white54),
            ),
          )
        else
        ...professionalData!.servicePlans.map((service) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: ListTile(
              title: Text(service.title),
              subtitle: Text(
                'Descrição: ${service.description}\n'
                    'Duração: ${service.durationInDays} dias\n'
                    'Preço: R\$ ${service.price.toStringAsFixed(2)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showEditServiceDialog(service.id, service.title, service.description, service.durationInDays, service.price);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await _deleteService(service.id);
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        // Clients Section
        _buildSectionTitle('Clientes'),
        if (professionalClients.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Nenhum cliente cadastrado.',
              style: TextStyle(fontSize: 16, color: Colors.white54),
            ),
          )
        else
        ...professionalClients.map((client) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
            child: ExpansionTile(
              title: Text(client.name),
              subtitle: Text('E-mail: ${client.email}'),
              children: [
                ...client.servicePlans.map((plan) {
                  return ListTile(
                    title: Text(plan.servicePlan.title),
                    subtitle: Text(
                      'Período: ${DateFormat('dd/MM/yyyy').format(plan.startDate)} - ${DateFormat('dd/MM/yyyy').format(plan.endDate)}',
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Cancelar Plano de Serviço'),
                              content: Text('Tem certeza que deseja cancelar este plano de serviço para ${client.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _cancelClientServicePlan(client.id, plan.servicePlan.id);
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Confirmar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Cancelar'),
                    ),
                  );
                }).toList(),
                TextButton(
                  onPressed: () {
                    // Add logic to message the client
                  },
                  child: const Text('Mensagem'),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Future<void> _deleteService(String serviceId) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text('Tem certeza que deseja excluir este serviço?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ProfessionalManagementService.deleteServicePlanByIdAsync(serviceId);
                  await _loadClientData(); // Reload data after deletion
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Serviço excluído com sucesso!')),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Excluir'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Erro ao excluir serviço: $e');
    }
  }

  Future<void> _cancelClientServicePlan(String clientId, String servicePlanId) async {
    try {
      await ProfessionalManagementService.deleteServicePlanFromClientAsync(clientId, servicePlanId);
      await _loadClientData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plano de serviço cancelado com sucesso!')),
      );
    } catch (e) {
      print('Erro ao cancelar plano de serviço: $e');
    }
  }

  void _showEditServiceDialog(String servicePlanId, String currentTitle, String currentDescription, int currentDuration, double currentPrice) {
    final TextEditingController titleController = TextEditingController(text: currentTitle);
    final TextEditingController descriptionController = TextEditingController(text: currentDescription);
    final TextEditingController durationController = TextEditingController(text: currentDuration.toString());
    final TextEditingController priceController = TextEditingController(text: currentPrice.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Serviço'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duração (em dias)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Preço',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
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
                  final String? updatedTitle = titleController.text.isNotEmpty ? titleController.text : null;
                  final String? updatedDescription = descriptionController.text.isNotEmpty ? descriptionController.text : null;
                  final int? updatedDuration = int.tryParse(durationController.text);
                  final double? updatedPrice = double.tryParse(priceController.text);

                  await ProfessionalManagementService.updateServicePlanByIdAsync(
                    servicePlanId,
                    updatedTitle,
                    updatedDescription,
                    updatedDuration,
                    updatedPrice,
                  );

                  await _loadClientData();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Serviço atualizado com sucesso!')),
                  );
                } catch (e) {
                  print('Erro ao atualizar serviço: $e');
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
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
    if(clientData!.servicePlans.isEmpty){
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Nenhum plano está ativo no momento.',
          style: TextStyle(fontSize: 16, color: Colors.white54),
        ),
      );
    }

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
    if(recommendedProfessionals.isEmpty)
    {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Nenhum profissional recomendado no momento.',
          style: TextStyle(fontSize: 16, color: Colors.white54),
        ),
      );
    }

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
