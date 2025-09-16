import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/nutritionService/daily_menu_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_dto.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/daily_menu_service.dart';
import 'package:shape_up_app/services/professional_management_service.dart';

class Nutrition extends StatefulWidget {
  const Nutrition({super.key});

  @override
  State<Nutrition> createState() => _NutritionState();
}

class _NutritionState extends State<Nutrition>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ClientDto? clientData;
  List<ClientDto> clients = [];
  late Future<List<DailyMenuDto>> _myDailyMenusFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClientData();
    _myDailyMenusFuture = _fetchDailyMenus();
  }

  Future<void> _loadClientData() async {
    try {
      final profileId = await AuthenticationService.getProfileId();
      final client = await ProfessionalManagementService.getClientByIdAsync(
        profileId,
      );

      if (client.isNutritionist) {
        final fetchedClients =
        await ProfessionalManagementService.getProfessionalClientsAsync(profileId);
        setState(() {
          clients = fetchedClients;
        });
      }

      setState(() {
        clientData = client;
      });
    } catch (e) {
      print("Erro ao carregar dados do cliente: $e");
    }
  }

  Future<List<DailyMenuDto>> _fetchDailyMenus() async {
    final userId = await AuthenticationService.getProfileId();
    return await DailyMenuService.ListDailyMenus(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrição", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF101827),
        bottom: clientData != null && clientData!.isNutritionist
            ? TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.greenAccent,
          tabs: const [
            Tab(text: "Meus Cardápios"),
            Tab(text: "Meus Clientes"),
          ],
        )
            : null,
      ),
      body: clientData != null && clientData!.isNutritionist
          ? TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildMyDailyMenusSection(),
          _buildClientsDailyMenusSection(),
        ],
      )
          : _buildMyDailyMenusSection(),
    );
  }

  Widget _buildMyDailyMenusSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Meus Cardápios",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                // TODO: implementar navegação para CreateDailyMenuPage
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<DailyMenuDto>>(
            future: _myDailyMenusFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.green));
              } else if (snapshot.hasError) {
                return Center(
                    child: Text("Erro: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text("Nenhum cardápio encontrado.",
                        style: TextStyle(color: Colors.white70)));
              }

              final menus = snapshot.data!;
              return ListView.builder(
                itemCount: menus.length,
                itemBuilder: (context, index) {
                  final DailyMenuDto menu = menus[index];
                  return Card(
                    color: const Color(0xFF2A2A3D),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(menu.dayOfWeek!.split(" ")[0],
                          style: const TextStyle(color: Colors.white)),
                      subtitle: const Text("Toque para ver detalhes",
                          style: TextStyle(color: Colors.white70)),
                      onTap: () {
                        // TODO: implementar navegação para NutritionDetails
                      },
                    ),
                  );
                },
              );
            },
          ),
        )
      ]),
    );
  }

  Widget _buildClientsDailyMenusSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return Card(
            color: const Color(0xFF2A2A3D),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(client.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text("Toque para ver cardápios",
                  style: TextStyle(color: Colors.white70)),
              children: [
                FutureBuilder<List<DailyMenuDto>>(
                  future: DailyMenuService.ListDailyMenus(client.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: Colors.green),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Erro: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red)),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("Nenhum cardápio encontrado.",
                            style: TextStyle(color: Colors.white70)),
                      );
                    }

                    final menus = snapshot.data!;
                    return Column(
                      children: menus.map((menu) {
                        return ListTile(
                          title: Text(menu.dayOfWeek!.split(" ")[0],
                              style: const TextStyle(color: Colors.white)),
                          onTap: () {
                            // TODO: implementar navegação para NutritionDetails
                          },
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
