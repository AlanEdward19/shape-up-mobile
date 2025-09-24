import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/nutritionService/daily_menu_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/food_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/dish_dto.dart'; 
import 'package:shape_up_app/dtos/professionalManagementService/client_dto.dart';
import 'package:shape_up_app/pages/create_daily_menu_page.dart';
import 'package:shape_up_app/pages/create_food_page.dart';
import 'package:shape_up_app/pages/create_dish_page.dart'; 
import 'package:shape_up_app/pages/food_details_page.dart';
import 'package:shape_up_app/pages/dish_details_page.dart'; // Importa a nova página
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/daily_menu_service.dart';
import 'package:shape_up_app/services/dish_service.dart'; 
import 'package:shape_up_app/services/professional_management_service.dart';
import 'package:shape_up_app/services/user_food_service.dart'; 
import 'package:shape_up_app/services/public_food_service.dart';

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
  late Future<List<FoodDto>> _myFoodsFuture;
  late Future<List<DishDto>> _myDishesFuture; 
  bool _isDeletingFood = false;
  bool _isDeletingDish = false; 

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadClientData();
    _myDailyMenusFuture = _fetchDailyMenus();
    _myFoodsFuture = _fetchMyFoods();
    _myDishesFuture = _fetchMyDishes(); 
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
    if (userId.isEmpty) {
      print("FetchDailyMenus: userId está vazio.");
      return [];
    }
    print("FetchDailyMenus: Buscando cardápios para o userId: $userId");
    try {
      final menus = await DailyMenuService.listDailyMenus(userId);
      print("FetchDailyMenus: ${menus.length} cardápios encontrados.");
      return menus;
    } catch (e) {
      print("FetchDailyMenus: Erro ao buscar cardápios: $e");
      rethrow;
    }
  }

  Future<List<FoodDto>> _fetchMyFoods() async {
    final userId = await AuthenticationService.getProfileId();
    if (userId.isEmpty) {
      print("FetchMyFoods: userId está vazio.");
      return [];
    }
    print("FetchMyFoods: Buscando comidas para o userId: $userId");

    List<FoodDto> userFoods = [];
    List<FoodDto> usedPublicFoods = [];
    String? errorSource;

    try {
      print("FetchMyFoods: Tentando buscar UserFoods...");
      userFoods = await UserFoodService.listUserFoods(userId: userId, rows: 100);
      print("FetchMyFoods: UserFoods buscadas: ${userFoods.length}");
    } catch (e) {
      print("FetchMyFoods: Erro ao buscar UserFoods: $e");
      errorSource = "UserFoods";
    }

    try {
      print("FetchMyFoods: Tentando buscar UsedPublicFoods...");
      usedPublicFoods = await PublicFoodService.listUsedByUserPublicFoods(userId: userId, rows: 100);
      print("FetchMyFoods: UsedPublicFoods buscadas: ${usedPublicFoods.length}");
    } catch (e) {
      print("FetchMyFoods: Erro ao buscar UsedPublicFoods: $e");
      if (errorSource == null) errorSource = "UsedPublicFoods"; 
    }

    if (errorSource != null) {
      throw Exception("Falha ao carregar lista de comidas de '$errorSource'. Verifique os logs para detalhes.");
    }
    
    final combinedFoods = <String, FoodDto>{};
    for (var food in userFoods) {
      if (food.id.isNotEmpty) combinedFoods[food.id] = food;
    }
    for (var food in usedPublicFoods) {
      if (food.id.isNotEmpty) combinedFoods[food.id] = food;
    }
    return combinedFoods.values.toList();
  }

 Future<List<DishDto>> _fetchMyDishes() async {
    final userId = await AuthenticationService.getProfileId();
    if (userId.isEmpty) {
      return [];
    }
    try {
      final dishes = await DishService.listDishes(userId: userId, rows: 100);

      return dishes;
    } catch (e) {
      print("FetchMyDishes: Erro ao buscar pratos: $e");
      rethrow; 
    }
  }

  void _refreshMyDailyMenus() {
    setState(() {
      _myDailyMenusFuture = _fetchDailyMenus();
    });
  }

  void _refreshMyFoods() {
    setState(() {
      _myFoodsFuture = _fetchMyFoods();
    });
  }

  void _refreshMyDishes() {
    setState(() {
      _myDishesFuture = _fetchMyDishes();
    });
  }

  void _navigateToCreateDailyMenuPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateDailyMenuPage()),
    );
    if (result == true) _refreshMyDailyMenus();
  }
  
  void _navigateToAddFoodPage() async { 
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateFoodPage()), 
    );
    if (result == true) {
      _refreshMyFoods(); 
    }
  }

  void _navigateToCreateDishPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateDishPage()), 
    );
    if (result == true) {
      _refreshMyDishes(); 
    }
  }

  Future<void> _showDeleteFoodConfirmationDialog(FoodDto food) async {
    if (_isDeletingFood) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C3E),
          title: const Text('Apagar Comida', style: TextStyle(color: Colors.white)),
          content: Text('Tem certeza de que deseja apagar "${food.name ?? 'esta comida'}"? Esta ação não pode ser desfeita.', style: const TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.greenAccent)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Sim, Apagar', style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isDeletingFood = true;
      });
      try {
        await UserFoodService.deleteUserFood(food.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('"${food.name ?? 'Comida'}" apagada com sucesso.')),
          );
          _refreshMyFoods(); 
        }
      } catch (e) {
        print("Erro ao apagar comida: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao apagar comida: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDeletingFood = false;
          });
        }
      }
    }
  }

  Future<void> _showDeleteDishConfirmationDialog(DishDto dish) async {
    if (_isDeletingDish) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C3E),
          title: const Text('Apagar Prato', style: TextStyle(color: Colors.white)),
          content: Text('Tem certeza de que deseja apagar "${dish.name}"? Esta ação não pode ser desfeita.', style: const TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.greenAccent)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Sim, Apagar', style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _isDeletingDish = true;
      });
      try {
        await DishService.deleteDish(dish.id); 
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Prato "${dish.name}" apagado com sucesso.')),
          );
          _refreshMyDishes();
        }
      } catch (e) {
        print("Erro ao apagar prato: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao apagar prato: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDeletingDish = false;
          });
        }
      }
    }
  }

  Widget _buildSectionHeader(String title, VoidCallback onAddPressed, {bool showAddButton = true}) {
    bool isCurrentlyDeleting = (title == "Minhas Comidas" && _isDeletingFood) || (title == "Meus Pratos" && _isDeletingDish);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        if (showAddButton)
          IconButton(icon: Icon(Icons.add_circle_outline, color: isCurrentlyDeleting ? Colors.grey : Colors.white, size: 28), onPressed: isCurrentlyDeleting ? null : onAddPressed),
      ],
    );
  }

  Widget _buildPlaceholderContent(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 16)),
      ),
    );
  }

  Widget _buildMyDailyMenusList() {
    return FutureBuilder<List<DailyMenuDto>>(
      future: _myDailyMenusFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator(color: Colors.greenAccent)));
        }
        if (snapshot.hasError) return _buildPlaceholderContent("Erro ao carregar cardápios: ${snapshot.error}");
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildPlaceholderContent("Nenhum cardápio diário. Toque + para adicionar.");

        final menus = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menus.length,
          itemBuilder: (context, index) {
            final menu = menus[index];
            return Card(
              color: const Color(0xFF2A2A3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 12, top: 4),
              child: ListTile(
                title: Text(menu.dayOfWeek?.split(" ")[0] ?? 'Dia não especificado', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text("Toque para ver detalhes", style: TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                onTap: () { print("Detalhes do cardápio: ${menu.id}"); },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyFoodsList() {
    return FutureBuilder<List<FoodDto>>(
      future: _myFoodsFuture,
      builder: (context, snapshot) {
        if (_isDeletingFood && snapshot.connectionState != ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator(color: Colors.orangeAccent)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator(color: Colors.greenAccent)));
        }
        if (snapshot.hasError) return _buildPlaceholderContent("Erro ao carregar comidas: ${snapshot.error}");
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildPlaceholderContent("Nenhuma comida salva. Toque em + para adicionar.");

        final foods = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true, 
          physics: const NeverScrollableScrollPhysics(), 
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            final bool isCurrentlyDeletingThis = _isDeletingFood; 
            return Card(
              color: const Color(0xFF2A2A3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 12, top: 4),
              child: ListTile(
                title: Text(food.name ?? 'Nome não disponível', style: TextStyle(color: isCurrentlyDeletingThis ? Colors.grey : Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text(food.brand ?? 'Marca não disponível', style: TextStyle(color: isCurrentlyDeletingThis ? Colors.grey[600] : Colors.white70)),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: isCurrentlyDeletingThis ? Colors.grey : Colors.redAccent),
                  onPressed: isCurrentlyDeletingThis ? null : () => _showDeleteFoodConfirmationDialog(food),
                ),
                onTap: isCurrentlyDeletingThis ? null : () async {

                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailsPage(food: food),
                    ),
                  );
                  if (result == true) {
                    _refreshMyFoods(); 
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyDishesList() {
    return FutureBuilder<List<DishDto>>(
      future: _myDishesFuture,
      builder: (context, snapshot) {
        if (_isDeletingDish && snapshot.connectionState != ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator(color: Colors.orangeAccent)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator(color: Colors.greenAccent)));
        }
        if (snapshot.hasError) {
          return _buildPlaceholderContent("Erro ao carregar pratos: ${snapshot.error}");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildPlaceholderContent("Nenhum prato personalizado. Toque + para criar.");
        }

        final dishes = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dishes.length,
          itemBuilder: (context, index) {
            final dish = dishes[index];
            final bool isCurrentlyDeletingThis = _isDeletingDish; 
            return Card(
              color: const Color(0xFF2A2A3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 12, top: 4),
              child: ListTile(
                title: Text(dish.name, style: TextStyle(color: isCurrentlyDeletingThis ? Colors.grey : Colors.white, fontWeight: FontWeight.w600)), 
                subtitle: Text("${dish.ingredients.length} comida(s) no prato", style: TextStyle(color: isCurrentlyDeletingThis ? Colors.grey[600] : Colors.white70)),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: isCurrentlyDeletingThis ? Colors.grey : Colors.redAccent),
                  onPressed: isCurrentlyDeletingThis ? null : () => _showDeleteDishConfirmationDialog(dish),
                ),
                onTap: isCurrentlyDeletingThis ? null : () async {

                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DishDetailsPage(dish: dish),
                    ),
                  );
                  if (result == true && mounted) {
                    _refreshMyDishes();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyNutritionSection() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader("Meus Cardápios Diários", _navigateToCreateDailyMenuPage),
        const SizedBox(height: 8),
        _buildMyDailyMenusList(),
        const Divider(color: Colors.grey, height: 40, thickness: 0.5),

        _buildSectionHeader("Minhas Refeições", () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionalidade "Minhas Refeições" em desenvolvimento.')));
        }),
        const SizedBox(height: 8),
        _buildPlaceholderContent("Nenhuma refeição personalizada. Toque + para criar."),
        const Divider(color: Colors.grey, height: 40, thickness: 0.5),

        _buildSectionHeader("Meus Pratos", _navigateToCreateDishPage), 
        const SizedBox(height: 8),
        _buildMyDishesList(), 
        const Divider(color: Colors.grey, height: 40, thickness: 0.5),

        _buildSectionHeader("Minhas Comidas", _navigateToAddFoodPage), 
        const SizedBox(height: 8),
        _buildMyFoodsList(),
      ],
    );
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
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: Colors.greenAccent,
                indicatorWeight: 3.0,
                tabs: const [
                  Tab(text: "Minha Nutrição"),
                  Tab(text: "Nutrição dos Clientes"),
                ],
              )
            : null,
      ),
      body: clientData != null && clientData!.isNutritionist
          ? TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildMyNutritionSection(),
                _buildClientsDailyMenusSection(),
              ],
            )
          : _buildMyNutritionSection(),
    );
  }

  Widget _buildClientsDailyMenusSection() {
    if (clients.isEmpty) return _buildPlaceholderContent("Nenhum cliente encontrado.");
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return Card(
            color: const Color(0xFF2A2A3D),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              iconColor: Colors.greenAccent,
              collapsedIconColor: Colors.white70,
              title: Text(client.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text("Toque para ver cardápios", style: TextStyle(color: Colors.white70)),
              children: [
                FutureBuilder<List<DailyMenuDto>>(
                  future: DailyMenuService.listDailyMenus(client.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator(color: Colors.greenAccent)));
                    }
                    if (snapshot.hasError) return Padding(padding: const EdgeInsets.all(16.0), child: Text("Erro: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)));
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const Padding(padding: const EdgeInsets.all(16.0), child: Text("Nenhum cardápio para este cliente.", style: TextStyle(color: Colors.white70)));

                    final menus = snapshot.data!;
                    return Column(
                      children: menus.map((menu) {
                        return ListTile(
                          title: Text(menu.dayOfWeek?.split(" ")[0] ?? 'Dia não especificado', style: const TextStyle(color: Colors.white)),
                          onTap: () { print("Detalhes do cardápio do cliente: ${menu.id}"); },
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
