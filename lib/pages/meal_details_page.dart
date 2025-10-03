import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/nutritionService/meal_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/dish_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/food_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/ingredient_input_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/nutritional_info_dto.dart';
import 'package:shape_up_app/enums/nutritionService/meal_type.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/dish_service.dart';
import 'package:shape_up_app/services/meal_service.dart';
import 'package:shape_up_app/services/user_food_service.dart';

class MealDetailsPage extends StatefulWidget {
  final MealDto meal;

  const MealDetailsPage({super.key, required this.meal});

  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  late TextEditingController _mealNameController;
  late MealType _selectedMealType;
  late List<DishDto> _editableDishes;
  late List<IngredientInputDto> _editableIngredients;

  List<DishDto> _availableDishes = [];
  List<FoodDto> _availableFoods = [];
  bool _isLoadingData = false;
  bool _isSaving = false;
  String? _loadingError;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _mealNameController = TextEditingController(text: widget.meal.name);
    _selectedMealType = widget.meal.type;
    _editableDishes = List<DishDto>.from(widget.meal.dishes);
    _editableIngredients = List<IngredientInputDto>.from(
        widget.meal.ingredients.map((e) => IngredientInputDto(foodId: e.food.id, quantity: e.quantity))
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingData = true;
      _loadingError = null;
    });
    try {
      final userId = await AuthenticationService.getProfileId();
      if (userId.isEmpty) throw Exception("Usuário não autenticado.");

      final dishesFuture = DishService.listDishes(userId: userId, rows: 1000);
      final foodsFuture = UserFoodService.listUserFoods(userId: userId, rows: 1000);

      final results = await Future.wait([dishesFuture, foodsFuture]);
      
      if (mounted) {
        setState(() {
          _availableDishes = results[0] as List<DishDto>;
          _availableFoods = results[1] as List<FoodDto>;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar dados: $e");
      if (mounted) {
        setState(() {
          _loadingError = "Erro ao carregar dados.";
          _isLoadingData = false;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await MealService.editMeal(
        widget.meal.id,
        name: _mealNameController.text,
        type: _selectedMealType,
        dishIds: _editableDishes.map((d) => d.id).toList(),
        ingredients: _editableIngredients,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refeição atualizada com sucesso!'), backgroundColor: Colors.blue),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Erro ao atualizar refeição: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar refeição: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal.name, style: TextStyle(color: _isSaving ? Colors.grey : Colors.white)),
        backgroundColor: const Color(0xFF101827),
        iconTheme: IconThemeData(color: _isSaving ? Colors.grey : Colors.white),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            )          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
            ),
        ],
      ),
      backgroundColor: const Color(0xFF1C1C2E),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : _buildMealForm(),
    );
  }

  Widget _buildMealForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _mealNameController,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              labelText: 'Nome da Refeição',
              labelStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
            ),
            validator: (value) => value == null || value.isEmpty ? 'Insira um nome para a refeição' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MealType>(
            value: _selectedMealType,
            items: MealType.values.map((type) {
              return DropdownMenuItem<MealType>(
                value: type,
                child: Text(type.toString().split('.').last, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedMealType = value);
            },
            dropdownColor: const Color(0xFF2C2C3E),
            decoration: const InputDecoration(
              labelText: 'Tipo de Refeição',
              labelStyle: TextStyle(color: Colors.white70),
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Pratos', () => _showAddDishDialog()),
          ..._editableDishes.map((dish) => ListTile(
            title: Text(dish.name, style: const TextStyle(color: Colors.white)),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
              onPressed: () => setState(() => _editableDishes.remove(dish)),
            ),
          )),
          const SizedBox(height: 24),
          _buildSectionHeader('Ingredientes Adicionais', () => _showAddFoodDialog()),
          ..._editableIngredients.map((ingredient) {
            final food = _availableFoods.firstWhere((f) => f.id == ingredient.foodId, orElse: () => FoodDto(id: '', name: 'Desconhecido', createdBy: '', userId: '', isRevised: false, nutritionalInfo: NutritionalInfoDto(servingSize: 0.0)));
            return ListTile(
              title: Text(food.name ?? 'Ingrediente desconhecido', style: const TextStyle(color: Colors.white)),
              subtitle: Text('${ingredient.quantity}g', style: const TextStyle(color: Colors.white70)),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                onPressed: () => setState(() => _editableIngredients.remove(ingredient)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.add, color: Colors.blueAccent), onPressed: onAdd),
      ],
    );
  }

  void _showAddDishDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C3E),
          title: const Text('Adicionar Prato', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableDishes.length,
              itemBuilder: (context, index) {
                final dish = _availableDishes[index];
                return ListTile(
                  title: Text(dish.name, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      if (!_editableDishes.any((d) => d.id == dish.id)) {
                        _editableDishes.add(dish);
                      }
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddFoodDialog() {
    FoodDto? selectedFood;
    final quantityController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C3E),
          title: const Text('Adicionar Ingrediente', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<FoodDto>(
                value: selectedFood,
                items: _availableFoods.map((food) {
                  return DropdownMenuItem<FoodDto>(
                    value: food,
                    child: Text(food.name ?? '', style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) => selectedFood = value,
                dropdownColor: const Color(0xFF2C2C3E),
                decoration: const InputDecoration(labelText: 'Comida', labelStyle: TextStyle(color: Colors.white70)),
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantidade (g)', labelStyle: TextStyle(color: Colors.white70)),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent))),
            TextButton(
              onPressed: () {
                if (selectedFood != null) {
                  final quantity = double.tryParse(quantityController.text) ?? 100.0;
                  setState(() {
                    if (!_editableIngredients.any((i) => i.foodId == selectedFood!.id)) {
                      _editableIngredients.add(IngredientInputDto(foodId: selectedFood!.id, quantity: quantity));
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Adicionar', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }
}
