import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_professional_review_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/professional_score_dto.dart';
import 'package:shape_up_app/dtos/socialService/simplified_profile_dto.dart';
import 'package:shape_up_app/services/professional_management_service.dart';
import 'package:shape_up_app/services/social_service.dart';

class ProfessionalProfile extends StatefulWidget {
  final ProfessionalDto professional;
  final ProfessionalScoreDto? professionalScore;

  const ProfessionalProfile({
    required this.professional,
    required this.professionalScore,
    super.key,
  });

  @override
  _ProfessionalProfileState createState() => _ProfessionalProfileState();
}

class _ProfessionalProfileState extends State<ProfessionalProfile> {
  SimplifiedProfileDto? simplifiedProfile;
  List<ClientProfessionalReviewDto> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfessionalData();
  }

  Future<void> _loadProfessionalData() async {
    try {
      final reviewList = await ProfessionalManagementService.getProfessionalReviewsByIdAsync(widget.professional.id);
      final profile = await SocialService.viewProfileSimplifiedAsync(widget.professional.id);

      setState(() {
        reviews = reviewList;
        simplifiedProfile = profile;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading professional data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.professional.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF191F2B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    backgroundImage: NetworkImage(simplifiedProfile?.imageUrl ?? 'https://via.placeholder.com/150'), // Placeholder image
                    radius: 40,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.professional.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
            _buildSectionTitle('Planos Disponíveis'),
            ...widget.professional.servicePlans.map((plan) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(plan.title),
                  subtitle: Text(plan.description),
                  trailing: Text('R\$ ${plan.price.toStringAsFixed(2)}'),
                  onTap: () {
                    // Implementar lógica de contratar
                  },
                ),
              );
            }).toList(),

            // Reviews Section
            _buildSectionTitle('Avaliações'),
            if (reviews.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Nenhuma avaliação disponível.', style: TextStyle(color: Colors.white)),
              )
            else
              ...reviews.map((review) {
                return ListTile(
                  title: Text(
                    'Nota: ${review.rating}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  subtitle: Text(
                    review.comment,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}