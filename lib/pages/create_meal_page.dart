import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/nutritionService/dish_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/food_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/ingredient_input_dto.dart';
import 'package:shape_up_app/enums/nutritionService/meal_type.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/dish_service.dart';
import 'package:shape_up_app/services/meal_service.dart';
import 'package:shape_up_app/services/user_food_service.dart';
import 'package:shape_up_app/services/public_food_service.dart';

class CreateMealPage extends StatefulWidget {
  const CreateMealPage({super.key});

  @override
  State<CreateMealPage> createState() => _CreateMealPageState();
}

class _CreateMealPageState extends State<CreateMealPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  MealType _selectedMealType = MealType.Breakfast;
  bool _isLoading = false;
  bool _isSaving = false;

  List<DishDto> _availableDishes = [];
  List<FoodDto> _availableFoods = [];
  
  final List<DishDto> _selectedDishes = [];
  final List<IngredientInputDto> _selectedIngredients = [];
  final Map<String, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userId = await AuthenticationService.getProfileId();
      final dishesFuture = DishService.listDishes(userId: userId, rows: 200);
      final userFoodsFuture = UserFoodService.listUserFoods(userId: userId, rows: 200);
      final publicFoodsFuture = PublicFoodService.listUsedByUserPublicFoods(userId: userId, rows: 200);

      final results = await Future.wait([dishesFuture, userFoodsFuture, publicFoodsFuture]);

      final dishes = results[0] as List<DishDto>;
      final userFoods = results[1] as List<FoodDto>;
      final publicFoods = results[2] as List<FoodDto>;

      final combinedFoods = <String, FoodDto>{};
      for (var food in [...userFoods, ...publicFoods]) {
        if (food.id.isNotEmpty) combinedFoods[food.id] = food;
      }
      
      final allFoods = combinedFoods.values.toList();
      for (final food in allFoods) {
        _quantityControllers[food.id] = TextEditingController();
      }

      setState(() {
        _availableDishes = dishes;
        _availableFoods = allFoods;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _createMeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDishes.isEmpty && _selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um prato ou ingrediente.'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await MealService.createMealForSameUser(
        name: _nameController.text,
        type: _selectedMealType,
        dishIds: _selectedDishes.map((d) => d.id).toList(),
        ingredients: _selectedIngredients,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refeição criada com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar refeição: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
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
      default:
        return 'Desconhecido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        title: const Text('Criar Nova Refeição', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF101827),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
          : _buildForm(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _createMeal,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isSaving
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black))
              : const Text('Salvar Refeição', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nome da Refeição',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF2C2C3E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Por favor, insira um nome';
                return null;
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<MealType>(
              value: _selectedMealType,
              dropdownColor: const Color(0xFF2C2C3E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tipo de Refeição',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF2C2C3E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              items: MealType.values.map((MealType type) {
                return DropdownMenuItem<MealType>(
                  value: type,
                  child: Text(_mealTypeToPortugueseString(type)),
                );
              }).toList(),
              onChanged: (MealType? newValue) {
                if (newValue != null) setState(() => _selectedMealType = newValue);
              },
            ),
            const SizedBox(height: 24),
            _buildDishesExpansionTile(),
            const SizedBox(height: 16),
            _buildIngredientsExpansionTile(),
            const SizedBox(height: 80), // Space for bottom nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildDishesExpansionTile() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        title: Text('Pratos (${_selectedDishes.length} selecionados)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconColor: Colors.greenAccent,
        collapsedIconColor: Colors.white70,
        children: _availableDishes.isEmpty
            ? [const ListTile(title: Text("Nenhum prato encontrado.", style: TextStyle(color: Colors.white70)))]
            : _availableDishes.map((dish) {
                final isSelected = _selectedDishes.any((d) => d.id == dish.id);
                return CheckboxListTile(
                  title: Text(dish.name, style: const TextStyle(color: Colors.white)),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedDishes.add(dish);
                      } else {
                        _selectedDishes.removeWhere((d) => d.id == dish.id);
                      }
                    });
                  },
                  activeColor: Colors.greenAccent,
                  checkColor: Colors.black,
                );
              }).toList(),
      ),
    );
  }

  Widget _buildIngredientsExpansionTile() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        title: Text('Ingredientes Adicionais (${_selectedIngredients.length} selecionados)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconColor: Colors.greenAccent,
        collapsedIconColor: Colors.white70,
        children: _availableFoods.isEmpty
            ? [const ListTile(title: Text("Nenhuma comida encontrada.", style: TextStyle(color: Colors.white70)))]
            : _availableFoods.map((food) {
                final isSelected = _selectedIngredients.any((i) => i.foodId == food.id);
                return CheckboxListTile(
                  title: Text(food.name ?? 'Comida sem nome', style: const TextStyle(color: Colors.white)),
                  subtitle: Row(
                    children: [
                      Expanded(child: Text(food.brand ?? 'Sem marca', style: const TextStyle(color: Colors.white70))),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          controller: _quantityControllers[food.id],
                          style: const TextStyle(color: Colors.white),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Qtd (g)',
                            labelStyle: TextStyle(color: Colors.white70, fontSize: 14),
                            isDense: true,
                          ),
                          enabled: isSelected,
                          onChanged: (value) {
                            final quantity = double.tryParse(value);
                            if (quantity != null) {
                              final index = _selectedIngredients.indexWhere((i) => i.foodId == food.id);
                              if (index != -1) {
                                setState(() {
                                  _selectedIngredients[index] = IngredientInputDto(foodId: food.id, quantity: quantity);
                                });
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        final quantity = double.tryParse(_quantityControllers[food.id]!.text) ?? 0.0;
                        _selectedIngredients.add(IngredientInputDto(foodId: food.id, quantity: quantity));
                      } else {
                        _selectedIngredients.removeWhere((i) => i.foodId == food.id);
                        _quantityControllers[food.id]!.clear();
                      }
                    });
                  },
                  activeColor: Colors.greenAccent,
                  checkColor: Colors.black,
                );
              }).toList(),
      ),
    );
  }
}
