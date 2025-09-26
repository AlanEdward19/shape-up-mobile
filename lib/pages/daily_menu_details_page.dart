import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/nutritionService/daily_menu_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/meal_dto.dart';
import 'package:shape_up_app/enums/nutritionService/DayOfWeek.dart';
import 'package:shape_up_app/services/daily_menu_service.dart';
import 'package:shape_up_app/services/meal_service.dart';
import 'package:shape_up_app/services/authentication_service.dart';

class DailyMenuDetailsPage extends StatefulWidget {
  final DailyMenuDto dailyMenu;

  const DailyMenuDetailsPage({super.key, required this.dailyMenu});

  @override
  State<DailyMenuDetailsPage> createState() => _DailyMenuDetailsPageState();
}

class _DailyMenuDetailsPageState extends State<DailyMenuDetailsPage> {
  late DailyMenuDto _editableMenu;
  bool _isEditing = false;
  bool _isSaving = false;
  List<MealDto> _availableMeals = [];

  @override
  void initState() {
    super.initState();
    _editableMenu = widget.dailyMenu;
    _loadAvailableMeals();
  }

  Future<void> _loadAvailableMeals() async {
    try {
      final userId = await AuthenticationService.getProfileId();
      final meals = await MealService.listMeals(userId: userId, size: 200);
      if (mounted) {
        setState(() {
          _availableMeals = meals;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Map<String, double> _calculateTotalNutritionalInfo() {
    double totalCalories = 0, totalProteins = 0, totalCarbs = 0, totalFats = 0;
    for (var meal in _editableMenu.meals) {
      final nutritionalInfo = _calculateMealNutritionalInfo(meal);
      totalCalories += nutritionalInfo['calories']!;
      totalProteins += nutritionalInfo['proteins']!;
      totalCarbs += nutritionalInfo['carbs']!;
      totalFats += nutritionalInfo['fats']!;
    }
    return {
      'calories': totalCalories,
      'proteins': totalProteins,
      'carbs': totalCarbs,
      'fats': totalFats,
    };
  }

  Map<String, double> _calculateMealNutritionalInfo(MealDto meal) {
    double cals = 0, prots = 0, carbs = 0, fats = 0;
    for (var dish in meal.dishes) {
      for (var ingredient in dish.ingredients) {
        final info = ingredient.food.nutritionalInfo;
        final ratio = ingredient.quantity / info.servingSize;
        cals += (info.calories ?? 0) * ratio;
        prots += (info.macronutrients?.proteins ?? 0) * ratio;
        carbs += (info.macronutrients?.carbohydrates?.total ?? 0) * ratio;
        fats += (info.macronutrients?.fats?.total ?? 0) * ratio;
      }
    }
    for (var ingredient in meal.ingredients) {
      final info = ingredient.food.nutritionalInfo;
      final ratio = ingredient.quantity / info.servingSize;
      cals += (info.calories ?? 0) * ratio;
      prots += (info.macronutrients?.proteins ?? 0) * ratio;
      carbs += (info.macronutrients?.carbohydrates?.total ?? 0) * ratio;
      fats += (info.macronutrients?.fats?.total ?? 0) * ratio;
    }
    return {'calories': cals, 'proteins': prots, 'carbs': carbs, 'fats': fats};
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    try {
      await DailyMenuService.editDailyMenu(
        _editableMenu.id,
        dayOfWeek: _editableMenu.dayOfWeek,
        mealIds: _editableMenu.meals.map((m) => m.id).toList(),
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalNutritionalInfo = _calculateTotalNutritionalInfo();

    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        title: Text(_editableMenu.dayOfWeek != null ? dayOfWeekToPortugueseString(_editableMenu.dayOfWeek!) : 'Cardápio', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF101827),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_isEditing)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges)
          else
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _isEditing = true)),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNutritionalSummary(totalNutritionalInfo),
                const SizedBox(height: 24),
                if (_isEditing) _buildDayOfWeekSelector(),
                ..._editableMenu.meals.map((meal) => _buildMealCard(meal)),
                if (_isEditing) _buildAddMealButton(),
              ],
            ),
    );
  }

  Widget _buildNutritionalSummary(Map<String, double> nutritionalInfo) {
    return Card(
      color: const Color(0xFF2A2A3D),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo Nutricional do Dia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calorias: ${nutritionalInfo['calories']!.toStringAsFixed(0)} kcal', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                Text('Proteínas: ${nutritionalInfo['proteins']!.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Carboidratos: ${nutritionalInfo['carbs']!.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                Text('Gorduras: ${nutritionalInfo['fats']!.toStringAsFixed(1)}g', style: const TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayOfWeekSelector() {
    return DropdownButtonFormField<DayOfWeek>(
      value: _editableMenu.dayOfWeek,
      items: DayOfWeek.values.where((d) => d != DayOfWeek.empty).map((day) {
        return DropdownMenuItem(value: day, child: Text(dayOfWeekToPortugueseString(day), style: const TextStyle(color: Colors.white)));
      }).toList(),
      onChanged: (DayOfWeek? newValue) {
        setState(() {
          _editableMenu = DailyMenuDto(
            id: _editableMenu.id,
            createdBy: _editableMenu.createdBy,
            userId: _editableMenu.userId,
            dayOfWeek: newValue,
            meals: _editableMenu.meals,
          );
        });
      },
      dropdownColor: const Color(0xFF2C2C3E),
      decoration: const InputDecoration(labelText: 'Dia da Semana', labelStyle: TextStyle(color: Colors.white70)),
    );
  }

  Widget _buildMealCard(MealDto meal) {
    final mealNutritionalInfo = _calculateMealNutritionalInfo(meal);
    return Card(
      color: const Color(0xFF2C2C3E),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(meal.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('${mealNutritionalInfo['calories']!.toStringAsFixed(0)} kcal', style: const TextStyle(color: Colors.white70)),
        trailing: _isEditing ? IconButton(icon: const Icon(Icons.remove_circle, color: Colors.redAccent), onPressed: () => setState(() => _editableMenu.meals.remove(meal))) : null,
        children: meal.dishes.map((dish) => ListTile(title: Text(dish.name, style: const TextStyle(color: Colors.white70)))).toList(),
      ),
    );
  }

  Widget _buildAddMealButton() {
    return TextButton.icon(
      icon: const Icon(Icons.add, color: Colors.greenAccent),
      label: const Text('Adicionar Refeição', style: TextStyle(color: Colors.greenAccent)),
      onPressed: () => _showAddMealDialog(),
    );
  }

  void _showAddMealDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C3E),
          title: const Text('Adicionar Refeição', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableMeals.length,
              itemBuilder: (context, index) {
                final meal = _availableMeals[index];
                return ListTile(
                  title: Text(meal.name, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      if (!_editableMenu.meals.any((m) => m.id == meal.id)) {
                        _editableMenu.meals.add(meal);
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
}
