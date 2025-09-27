import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/nutritionService/daily_menu_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/food_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/dish_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/meal_dto.dart';
import 'package:shape_up_app/dtos/professionalManagementService/client_dto.dart';
import 'package:shape_up_app/enums/nutritionService/DayOfWeek.dart';
import 'package:shape_up_app/enums/nutritionService/meal_type.dart';
import 'package:shape_up_app/pages/create_daily_menu_page.dart';
import 'package:shape_up_app/pages/create_food_page.dart';
import 'package:shape_up_app/pages/create_dish_page.dart';
import 'package:shape_up_app/pages/create_meal_page.dart';
import 'package:shape_up_app/pages/daily_menu_details_page.dart';
import 'package:shape_up_app/pages/food_details_page.dart';
import 'package:shape_up_app/pages/dish_details_page.dart';
import 'package:shape_up_app/pages/meal_details_page.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/daily_menu_service.dart';
import 'package:shape_up_app/services/dish_service.dart';
import 'package:shape_up_app/services/meal_service.dart';
import 'package:shape_up_app/services/professional_management_service.dart';
import 'package:shape_up_app/services/user_food_service.dart';
import 'package:shape_up_app/services/public_food_service.dart';

import '../services/user_nutrition.dart';

class Nutrition extends StatefulWidget {
  const Nutrition({super.key});

  @override
  State<Nutrition> createState() => _NutritionState();
}

class _NutritionState extends State<Nutrition>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ClientDto? clientData;
  List<ClientDto> clients = [];
  late Future<List<DailyMenuDto>> _myDailyMenusFuture;
  late Future<List<FoodDto>> _myFoodsFuture;
  late Future<List<DishDto>> _myDishesFuture;
  late Future<List<MealDto>> _myMealsFuture;
  bool _isDeletingFood = false;
  bool _isDeletingDish = false;
  bool _isDeletingMeal = false;
  bool _isDeletingDailyMenu = false;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadClientData();
    _myDailyMenusFuture = _fetchDailyMenus();
    _myFoodsFuture = _fetchMyFoods();
    _myDishesFuture = _fetchMyDishes();
    _myMealsFuture = _fetchMyMeals();
  }

  Future<void> _refreshAllData() async {
    // Usamos Future.wait para buscar tudo em paralelo e otimizar o tempo.
    await Future.wait([
      _fetchDailyMenus(),
      _fetchMyFoods(),
      _fetchMyDishes(),
      _fetchMyMeals(),
    ]);

    // Após todas as buscas terminarem, recriamos os Futures para que os
    // FutureBuilders na tela sejam reconstruídos com os novos dados.
    setState(() {
      _myDailyMenusFuture = _fetchDailyMenus();
      _myFoodsFuture = _fetchMyFoods();
      _myDishesFuture = _fetchMyDishes();
      _myMealsFuture = _fetchMyMeals();
    });
  }
  Future<void> _consolidateDailyMenus() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C3E),
          title: const Text('Consolidar Plano', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Isso irá criar ou substituir seu plano nutricional com os cardápios diários listados. Deseja continuar?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Consolidar', style: TextStyle(color: Colors.greenAccent)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consolidando plano...')),
    );

    try {
      final userId = await AuthenticationService.getProfileId();
      final nutritionManagerId = userId;
      final dailyMenus = await _myDailyMenusFuture;

      if (dailyMenus.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você precisa ter pelo menos um cardápio diário para consolidar.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }

      final dailyMenuIds = dailyMenus.map((menu) => menu.id).toList();

      // --- LÓGICA DE CRIAR OU ATUALIZAR ---

      // 1. Verifica se já existe um plano para o usuário
      final existingPlan = await UserNutrition.getUserNutritionByUserId(userId);

      if (existingPlan != null) {
        // 2. Se existe, chama o metodo de EDIÇÃO
        await UserNutrition.editUserNutrition(
          existingPlan.id, // Usa o ID do plano existente
          nutritionManagerId: nutritionManagerId,
          dailyMenuIds: dailyMenuIds,
        );
      } else {
        // 3. Se não existe, chama o metodo de CRIAÇÃO
        await UserNutrition.createUserNutrition(
          userId: userId,
          nutritionManagerId: nutritionManagerId,
          dailyMenuIds: dailyMenuIds,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plano nutricional consolidado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Erro ao consolidar plano nutricional: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao consolidar o plano: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
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
      } else {
        _tabController = TabController(length: 2, vsync: this);
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

  Future<List<MealDto>> _fetchMyMeals() async {
    final userId = await AuthenticationService.getProfileId();
    if (userId.isEmpty) {
      return [];
    }
    try {
      final meals = await MealService.listMeals(userId: userId, size: 100);
      return meals;
    } catch (e) {
      print("FetchMyMeals: Erro ao buscar refeições: $e");
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

  void _refreshMyMeals() {
    setState(() {
      _myMealsFuture = _fetchMyMeals();
    });
  }

  void _navigateToCreateDailyMenuPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateDailyMenuPage()),
    );
    if (result == true) _refreshMyDailyMenus();
  }

  void _navigateToDailyMenuDetailsPage(DailyMenuDto menu) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => DailyMenuDetailsPage(dailyMenu: menu)),
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

  void _navigateToCreateMealPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateMealPage()),
    );
    if (result == true) {
      _refreshMyMeals();
    }
  }

  void _navigateToMealDetailsPage(MealDto meal) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => MealDetailsPage(meal: meal)),
    );
    if (result == true) {
      _refreshMyMeals();
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
          content: Text('Tem certeza de que deseja apagar "${food.name}"? Esta ação não pode ser desfeita.', style: const TextStyle(color: Colors.white70)),
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
            SnackBar(content: Text('"${food.name}" apagada com sucesso.')),
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

  Future<void> _showDeleteMealConfirmationDialog(MealDto meal) async {
    if (_isDeletingMeal) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C3E),
          title: const Text('Apagar Refeição', style: TextStyle(color: Colors.white)),
          content: Text('Tem certeza de que deseja apagar "${meal.name}"? Esta ação não pode ser desfeita.', style: const TextStyle(color: Colors.white70)),
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
        _isDeletingMeal = true;
      });
      try {
        await MealService.deleteMeal(meal.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Refeição "${meal.name}" apagada com sucesso.')),
          );
          _refreshMyMeals();
        }
      } catch (e) {
        print("Erro ao apagar refeição: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao apagar refeição: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isDeletingMeal = false;
          });
        }
      }
    }
  }

  Future<void> _showDeleteDailyMenuConfirmationDialog(DailyMenuDto menu) async {
    if (_isDeletingDailyMenu) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C3E),
          title: const Text('Apagar Cardápio Diário', style: TextStyle(color: Colors.white)),
          content: Text('Tem certeza de que deseja apagar o cardápio para "${menu.dayOfWeek?.toPortuguese() ?? 'o dia selecionado'}"?', style: const TextStyle(color: Colors.white70)),
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
      setState(() => _isDeletingDailyMenu = true);
      try {
        await DailyMenuService.deleteDailyMenu(menu.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cardápio para "${menu.dayOfWeek?.toPortuguese() ?? 'o dia'}" apagado com sucesso.')),
          );
          _refreshMyDailyMenus();
        }
      } catch (e) {
        print("Erro ao apagar cardápio: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao apagar cardápio: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isDeletingDailyMenu = false);
        }
      }
    }
  }

  Widget _buildSectionHeader(String title, VoidCallback onAddPressed, {bool showAddButton = true}) {
    bool isCurrentlyDeleting = (title == "Minhas Comidas" && _isDeletingFood) || 
                               (title == "Meus Pratos" && _isDeletingDish) || 
                               (title == "Minhas Refeições" && _isDeletingMeal) ||
                               (title == "Meus Cardápios Diários" && _isDeletingDailyMenu);
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
            final isCurrentlyDeletingThis = _isDeletingDailyMenu;
            return Card(
              color: const Color(0xFF2A2A3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 12, top: 4),
              child: ListTile(
                title: Text(menu.dayOfWeek?.toPortuguese() ?? 'Dia não especificado', style: TextStyle(color: isCurrentlyDeletingThis ? Colors.grey : Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text("${menu.meals.length} refeições", style: TextStyle(color: isCurrentlyDeletingThis ? Colors.grey[600] : Colors.white70)),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: isCurrentlyDeletingThis ? Colors.grey : Colors.redAccent),
                  onPressed: isCurrentlyDeletingThis ? null : () => _showDeleteDailyMenuConfirmationDialog(menu),
                ),
                onTap: isCurrentlyDeletingThis ? null : () => _navigateToDailyMenuDetailsPage(menu),
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
                title: Text(food.name, style: TextStyle(color: isCurrentlyDeletingThis ? Colors.grey : Colors.white, fontWeight: FontWeight.w600)),
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

  String _mealTypeToPortugueseString(MealType type) {
    switch (type) {
      case MealType.Breakfast:
        return 'Café da Manhã';
      case MealType.MorningSnack:
        return 'Lanche da Manhã';
      case MealType.Lunch:
        return 'Almoço';
      case MealType.AfternoonSnack:
        return 'Lanche da Tarde';
      case MealType.Dinner:
        return 'Jantar';
      case MealType.Supper:
        return 'Ceia';
      }
  }

  Map<String, double> _calculateMealNutritionalInfo(MealDto meal) {
    double totalCalories = 0;
    double totalProteins = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (var ingredient in meal.ingredients) {
      final food = ingredient.food;
      final nutritionalInfo = food.nutritionalInfo;
      if (nutritionalInfo.servingSize > 0) {
        final ratio = ingredient.quantity / nutritionalInfo.servingSize;
        totalCalories += (nutritionalInfo.calories ?? 0) * ratio;
        totalProteins += (nutritionalInfo.macronutrients?.proteins ?? 0) * ratio;
        totalCarbs += (nutritionalInfo.macronutrients?.carbohydrates?.total ?? 0) * ratio;
        totalFats += (nutritionalInfo.macronutrients?.fats?.total ?? 0) * ratio;
      }
    }

    for (var dish in meal.dishes) {
      for (var ingredient in dish.ingredients) {
        final food = ingredient.food;
        final nutritionalInfo = food.nutritionalInfo;
        if (nutritionalInfo.servingSize > 0) {
          final ratio = ingredient.quantity / nutritionalInfo.servingSize;
          totalCalories += (nutritionalInfo.calories ?? 0) * ratio;
          totalProteins += (nutritionalInfo.macronutrients?.proteins ?? 0) * ratio;
          totalCarbs += (nutritionalInfo.macronutrients?.carbohydrates?.total ?? 0) * ratio;
          totalFats += (nutritionalInfo.macronutrients?.fats?.total ?? 0) * ratio;
        }
      }
    }

    return {
      'calories': totalCalories,
      'proteins': totalProteins,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }

  Widget _buildMyMealsList() {
    return FutureBuilder<List<MealDto>>(
      future: _myMealsFuture,
      builder: (context, snapshot) {
        if (_isDeletingMeal && snapshot.connectionState != ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator(color: Colors.orangeAccent)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: CircularProgressIndicator(color: Colors.greenAccent)));
        }
        if (snapshot.hasError) {
          return _buildPlaceholderContent("Erro ao carregar refeições: ${snapshot.error}");
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildPlaceholderContent("Nenhuma refeição personalizada. Toque + para criar.");
        }

        final meals = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];
            final nutritionalInfo = _calculateMealNutritionalInfo(meal);
            final bool isCurrentlyDeletingThis = _isDeletingMeal;

            return Card(
              color: const Color(0xFF2A2A3D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 12, top: 4),
              child: ExpansionTile(
                iconColor: Colors.greenAccent,
                collapsedIconColor: Colors.white70,
                title: Text(meal.name, style: TextStyle(color: isCurrentlyDeletingThis ? Colors.grey : Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text("Tipo: ${_mealTypeToPortugueseString(meal.type)}", style: TextStyle(color: isCurrentlyDeletingThis ? Colors.grey[600] : Colors.white70)),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 8),
                        Text('Informações Nutricionais Totais:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Calorias: ${nutritionalInfo['calories']!.toStringAsFixed(0)} kcal', style: const TextStyle(color: Colors.white70)),
                            Text('Proteínas: ${nutritionalInfo['proteins']!.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Carboidratos: ${nutritionalInfo['carbs']!.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.white70)),
                            Text('Gorduras: ${nutritionalInfo['fats']!.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24),
                        if (meal.dishes.isNotEmpty) ...[
                          const Text('Pratos:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          ...meal.dishes.map((dish) => Text('- ${dish.name}', style: const TextStyle(color: Colors.white70))),
                          const SizedBox(height: 12),
                        ],
                        if (meal.ingredients.isNotEmpty) ...[
                          const Text('Ingredientes Adicionais:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          ...meal.ingredients.map((ingredient) => Text('- ${ingredient.food.name} (${ingredient.quantity.toStringAsFixed(0)}g)', style: const TextStyle(color: Colors.white70))),
                          const SizedBox(height: 12),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: isCurrentlyDeletingThis ? null : () => _showDeleteMealConfirmationDialog(meal),
                              child: Text('Apagar', style: TextStyle(color: isCurrentlyDeletingThis ? Colors.grey : Colors.redAccent)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: isCurrentlyDeletingThis ? null : () => _navigateToMealDetailsPage(meal),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                disabledBackgroundColor: Colors.grey[600],
                              ),
                              child: const Text('Editar', style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildMyNutritionSection() {
    return RefreshIndicator(color: Colors.white,
        backgroundColor: const Color(0xFF101827).withOpacity(0.8),
        onRefresh: _refreshAllData,
        child: ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- Seção Minhas Comidas ---
        Card(
          color: const Color(0xFF2A2A3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 16), // Espaçamento entre os cards
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            iconColor: Colors.greenAccent,
            collapsedIconColor: Colors.white70,
            title: _buildSectionHeader("Comidas", _navigateToAddFoodPage),
            subtitle: const Text("Toque para expandir e ver a lista", style: TextStyle(color: Colors.white70, fontSize: 12)),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildMyFoodsList(),
              ),
            ],
          ),
        ),

        // --- Seção Meus Pratos ---
        Card(
          color: const Color(0xFF2A2A3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 16), // Espaçamento
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            iconColor: Colors.greenAccent,
            collapsedIconColor: Colors.white70,
            title: _buildSectionHeader("Pratos", _navigateToCreateDishPage),
            subtitle: const Text("Toque para expandir e ver a lista", style: TextStyle(color: Colors.white70, fontSize: 12)),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildMyDishesList(),
              ),
            ],
          ),
        ),

        // --- Seção Minhas Refeições ---
        Card(
          color: const Color(0xFF2A2A3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 16), // Espaçamento
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            iconColor: Colors.greenAccent,
            collapsedIconColor: Colors.white70,
            title: _buildSectionHeader("Refeições", _navigateToCreateMealPage),
            subtitle: const Text("Toque para expandir e ver a lista", style: TextStyle(color: Colors.white70, fontSize: 12)),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildMyMealsList(),
              ),
            ],
          ),
        ),

        // --- Seção Meus Cardápios Diários ---
        Card(
          color: const Color(0xFF2A2A3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 16), // Espaçamento
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            iconColor: Colors.greenAccent,
            collapsedIconColor: Colors.white70,
            title: _buildSectionHeader("Cardápios Diários", _navigateToCreateDailyMenuPage),
            subtitle: const Text("Toque para expandir e ver a lista", style: TextStyle(color: Colors.white70, fontSize: 12)),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildMyDailyMenusList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24), // Espaçamento antes do botão
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline, color: Colors.black),
          label: const Text(
            'Consolidar Plano Nutricional',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _consolidateDailyMenus, // Chama a nova função que vamos criar
        ),
        const SizedBox(height: 16),
      ],
    ));

  }

  Widget _buildTutorialSection() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        Text(
          'Como Montar uma Dieta',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 16),
        ListTile(
          leading: Icon(Icons.looks_one, color: Colors.greenAccent, size: 36),
          title: Text('Cadastre suas Comidas', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text('Vá em "Minhas Comidas" e adicione os alimentos que você e seus clientes mais consomem. Detalhe as informações nutricionais para melhores resultados.', style: TextStyle(color: Colors.white70)),
        ),
        Divider(color: Colors.grey, height: 30),
        ListTile(
          leading: Icon(Icons.looks_two, color: Colors.greenAccent, size: 36),
          title: Text('Crie Pratos Compostos', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text('Em "Meus Pratos", combine as comidas cadastradas para formar pratos completos, como "Salada de Frango" ou "Vitamina de Banana".', style: TextStyle(color: Colors.white70)),
        ),
        Divider(color: Colors.grey, height: 30),
        ListTile(
          leading: Icon(Icons.looks_3, color: Colors.greenAccent, size: 36),
          title: Text('Monte as Refeições', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text('Em "Minhas Refeições", agrupe pratos e/ou comidas para formar uma refeição completa, como um "Café da Manhã" ou "Almoço".', style: TextStyle(color: Colors.white70)),
        ),
        Divider(color: Colors.grey, height: 30),
        ListTile(
          leading: Icon(Icons.looks_4, color: Colors.greenAccent, size: 36),
          title: Text('Crie o Cardápio do Dia', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text('Finalmente, em "Meus Cardápios Diários", selecione as refeições que irão compor a dieta de um dia específico da semana.', style: TextStyle(color: Colors.white70)),
        ),

        Divider(color: Colors.grey, height: 30),
        ListTile(
          leading: Icon(Icons.notification_important, color: Colors.orangeAccent, size: 36),
          title: Text('Atenção às Alterações', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          subtitle: Text('As estruturas são independentes. Se você editar ou apagar uma Comida, os Pratos, Refeições ou Cardápios que a utilizam não serão atualizados automaticamente. Você precisará editá-los manualmente para refletir a mudança.', style: TextStyle(color: Colors.white70)),
        ),
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
        bottom: clientData != null
            ? TabBar(
                labelPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: Colors.greenAccent,
                indicatorWeight: 3.0,
                tabs: clientData!.isNutritionist
                    ? const [
                  Tab(text: "Minha Nutrição"),
                  Tab(text: "Clientes"),
                  Tab(text: "Tutorial"),
                ]
                    : const [
                  Tab(text: "Minha Nutrição"),
                  Tab(text: "Tutorial"),
                ],
              )
            : null,
      ),
      body: clientData != null
          ? TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: clientData!.isNutritionist
                  ? [
                _buildMyNutritionSection(),
                _buildClientsDailyMenusSection(),
                _buildTutorialSection(),
              ]
                  : [
                _buildMyNutritionSection(),
                _buildTutorialSection(),
              ],
            )
          : const Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
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
                      return const Padding(padding: const EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator(color: Colors.greenAccent)));
                    }
                    if (snapshot.hasError) return Padding(padding: const EdgeInsets.all(16.0), child: Text("Erro: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)));
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const Padding(padding: const EdgeInsets.all(16.0), child: Text("Nenhum cardápio para este cliente.", style: TextStyle(color: Colors.white70)));

                    final menus = snapshot.data!;
                    return Column(
                      children: menus.map((menu) {
                        return ListTile(
                          title: Text(menu.dayOfWeek?.toPortuguese() ?? 'Dia não especificado', style: const TextStyle(color: Colors.white)),
                          onTap: () => _navigateToDailyMenuDetailsPage(menu),
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
