import 'package:flutter/material.dart';

class ProfessionalProfile extends StatelessWidget {
  final String professionalName;
  final String professionalImage;

  const ProfessionalProfile({
    required this.professionalName,
    required this.professionalImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final availablePlans = [
      {'name': 'Plano Básico', 'description': 'Acesso básico', 'price': 'R\$ 100'},
      {'name': 'Plano Premium', 'description': 'Acesso completo', 'price': 'R\$ 200'},
    ];

    final reviews = [
      {'comment': 'Excelente profissional!', 'author': 'João'},
      {'comment': 'Muito atencioso e competente.', 'author': 'Maria'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(professionalName, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF191F2B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
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
                    backgroundImage: NetworkImage(professionalImage),
                    radius: 40,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    professionalName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Available Plans Section
            _buildSectionTitle('Planos Disponíveis'),
            ...availablePlans.map((plan) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(plan['name']!),
                  subtitle: Text(plan['description']!),
                  trailing: Text(plan['price']!),
                  onTap: () {
                    // Implementar lógica de contratar
                  },
                ),
              );
            }).toList(),

            // Reviews Section
            _buildSectionTitle('Avaliações'),
            ...reviews.map((review) {
              return ListTile(
                title: Text(review['author']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text(review['comment']!,  style: TextStyle(color: Colors.white)),
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