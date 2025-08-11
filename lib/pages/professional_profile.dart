import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_professional_review_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_score_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/service_plan_dto.dart';
import 'package:shape_up_app/dtos/socialService/simplified_profile_dto.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/professional_management_service.dart';
import 'package:shape_up_app/services/social_service.dart';
import 'package:shape_up_app/widgets/professionalManagementService/section_title.dart';

class ProfessionalProfile extends StatefulWidget {
  final ProfessionalDto professional;
  final ProfessionalScoreDto? professionalScore;
  final ClientDto loggedInUser;

  const ProfessionalProfile({
    required this.professional,
    required this.professionalScore,
    required this.loggedInUser,
    super.key,
  });

  @override
  _ProfessionalProfileState createState() => _ProfessionalProfileState();
}

class _ProfessionalProfileState extends State<ProfessionalProfile> {
  SimplifiedProfileDto? simplifiedProfile;
  List<ClientProfessionalReviewDto> reviews = [];
  bool isLoading = true;
  String loggedInUserProfileId = '';

  @override
  void initState() {
    super.initState();
    _loadProfessionalImageAndReviewList();
  }

  Future<void> _loadProfessionalImageAndReviewList() async {
    try {
      final reviewList =
      await ProfessionalManagementService.getProfessionalReviewsByIdAsync(
        widget.professional.id,
      );

      final profile = await SocialService.viewProfileSimplifiedAsync(
        widget.professional.id,
      );

      final loggedInUserId = await AuthenticationService.getProfileId();

      setState(() {
        reviews = reviewList;
        simplifiedProfile = profile;
        isLoading = false;
        loggedInUserProfileId = loggedInUserId;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading professional data: $e');
    }
  }

  Future<void> _loadProfessionalData() async {
    try {
      final updatedProfessionalScore = await ProfessionalManagementService.getProfessionalScoreByIdAsync(
        widget.professional.id,
      );

      final updatedProfessional = await ProfessionalManagementService.getProfessionalByIdAsync(
        widget.professional.id,
      );

      setState(() {
        widget.professionalScore?.averageScore = updatedProfessionalScore.averageScore;
        widget.professionalScore?.totalReviews = updatedProfessionalScore.totalReviews;
        widget.professionalScore?.lastUpdated = updatedProfessionalScore.lastUpdated;

        widget.professional.name = updatedProfessional.name;
        widget.professional.email = updatedProfessional.email;
        widget.professional.type = updatedProfessional.type;
        widget.professional.isVerified = updatedProfessional.isVerified;
        widget.professional.servicePlans.clear();
        widget.professional.servicePlans.addAll(updatedProfessional.servicePlans);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading professional data: $e');
    }
  }

  Future<void> _loadClientData() async {
    try {
      final loggedInUserId = await AuthenticationService.getProfileId();
      final client = await ProfessionalManagementService.getClientByIdAsync(
        loggedInUserId,
      );

      setState(() {
        widget.loggedInUser.servicePlans.clear();
        widget.loggedInUser.servicePlans.addAll(client.servicePlans);
      });
    } catch (e) {
      print('Error loading client data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.professional.name,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF191F2B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Professional Header
                      Container(
                        color: const Color(0xFF2A2F3C),
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                simplifiedProfile?.imageUrl ??
                                    'https://via.placeholder.com/150',
                              ), // Placeholder image
                              radius: 40,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.professional.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (widget.professionalScore != null)
                                  Text(
                                    'Avaliação: ${widget.professionalScore!.averageScore.toStringAsFixed(1)} (${widget.professionalScore!.totalReviews} reviews)',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Available Plans Section
                      SectionTitle(title: 'Planos Disponíveis'),
                      ...widget.professional.servicePlans.map((plan) {
                        final isPlanAlreadyHired = widget
                            .loggedInUser
                            .servicePlans
                            .any(
                              (servicePlan) =>
                                  servicePlan.servicePlan.id == plan.id,
                            );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 16.0,
                          ),
                          child: ListTile(
                            title: Text(plan.title),
                            subtitle: Text(plan.description),
                            trailing:
                                isPlanAlreadyHired
                                    ? const Text(
                                      'Já contratado',
                                      style: TextStyle(color: Colors.grey),
                                    )
                                    : Text(
                                      'R\$ ${plan.price.toStringAsFixed(2)}',
                                    ),
                            onTap:
                                isPlanAlreadyHired
                                    ? null
                                    : () {
                                      _showHireServicePlanDialog(plan);
                                    },
                            enabled: !isPlanAlreadyHired,
                          ),
                        );
                      }).toList(),

                      // Reviews Section
                      SectionTitle(title: 'Avaliações'),
                      if (reviews.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Nenhuma avaliação disponível.',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      else
                        ...reviews.map((review) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 16.0,
                            ),
                            color: const Color(0xFF2A2F3C),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0, left: 12.0, bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review.clientName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Nota: ${review.rating}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.amber,
                                        ),
                                      ),
                                      if (review.clientId ==
                                          loggedInUserProfileId)
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Colors.white70,
                                              ),
                                              onPressed: () {
                                                _showEditReviewDialog(review);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed: () {
                                                _showDeleteReviewDialog(
                                                  review.id,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  // Comentário (se houver)
                                  if (review.comment.isNotEmpty)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            review.comment,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        )

                                      ],
                                    ),
                                  const SizedBox(height: 8),
                                  // Última atualização
                                  Text(
                                    'Última atualização: ${review.lastUpdatedAt.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
                onRefresh: () async {
                  setState(() {
                    isLoading = true;
                  });

                  await _loadClientData();
                  await _loadProfessionalData();
                  await _loadProfessionalImageAndReviewList();
                },
              ),
    );
  }

  void _showDeleteReviewDialog(String reviewId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza que deseja excluir esta avaliação?'),
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
                  await ProfessionalManagementService.deleteProfessionalReviewAsync(
                    reviewId,
                  );

                  await _loadProfessionalImageAndReviewList();
                  await _loadProfessionalData();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avaliação excluída com sucesso!'),
                    ),
                  );
                } catch (e) {
                  print('Erro ao deletar avaliação: $e');
                }
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void _showHireServicePlanDialog(ServicePlanDto plan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contratar Plano'),
          content: Text(
            'Deseja contratar o plano "${plan.title}" por R\$ ${plan.price.toStringAsFixed(2)}?',
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
                  await ProfessionalManagementService.addServicePlanToClientAsync(
                    loggedInUserProfileId,
                    plan.id,
                  );

                  await _loadClientData();

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Plano contratado com sucesso!'),
                    ),
                  );
                } catch (e) {
                  print('Erro ao contratar plano: $e');
                }
              },
              child: const Text('Contratar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditReviewDialog(ClientProfessionalReviewDto review) {
    final TextEditingController commentController = TextEditingController(
      text: review.comment,
    );
    int updatedRating = review.rating;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Avaliação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo para atualizar a nota
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
              // Campo para atualizar o comentário
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
                  await ProfessionalManagementService.updateProfessionalReviewAsync(
                    review.id,
                    commentController.text,
                    updatedRating,
                  );

                  await _loadProfessionalImageAndReviewList();
                  await _loadProfessionalData();

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avaliação atualizada com sucesso!'),
                    ),
                  );
                } catch (e) {
                  print('Erro ao atualizar avaliação: $e');
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}
