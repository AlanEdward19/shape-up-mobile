import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/nutritionService/meal_dto.dart';
import 'package:shape_up_app/enums/nutritionService/DayOfWeek.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/daily_menu_service.dart';
import 'package:shape_up_app/services/meal_service.dart';

class CreateDailyMenuPage extends StatefulWidget {
  const CreateDailyMenuPage({super.key});

  @override
  State<CreateDailyMenuPage> createState() => _CreateDailyMenuPageState();
}

class _CreateDailyMenuPageState extends State<CreateDailyMenuPage> {
  final _formKey = GlobalKey<FormState>();
  DayOfWeek? _selectedDayOfWeek;
  List<MealDto> _availableMeals = [];
  final List<MealDto> _selectedMeals = [];
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);
    try {
      final userId = await AuthenticationService.getProfileId();
      final meals = await MealService.listMeals(userId: userId, size: 200);
      if (mounted) {
        setState(() {
          _availableMeals = meals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar refeições: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _createDailyMenu() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMeals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos uma refeição.'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await DailyMenuService.createDailyMenuForOwnUser(
        dayOfWeek: _selectedDayOfWeek,
        mealIds: _selectedMeals.map((m) => m.id).toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cardápio diário criado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar cardápio: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  String _dayOfWeekToPortugueseString(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.sunday:
        return 'Domingo';
      case DayOfWeek.monday:
        return 'Segunda-feira';
      case DayOfWeek.tuesday:
        return 'Terça-feira';
      case DayOfWeek.wednesday:
        return 'Quarta-feira';
      case DayOfWeek.thursday:
        return 'Quinta-feira';
      case DayOfWeek.friday:
        return 'Sexta-feira';
      case DayOfWeek.saturday:
        return 'Sábado';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        title: const Text('Criar Cardápio Diário', style: TextStyle(color: Colors.white)),
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
          onPressed: _isSaving ? null : _createDailyMenu,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isSaving
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black))
              : const Text('Salvar Cardápio', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DropdownButtonFormField<DayOfWeek>(
            value: _selectedDayOfWeek,
            hint: const Text('Selecione um dia da semana (opcional)', style: TextStyle(color: Colors.white70)),
            dropdownColor: const Color(0xFF2C2C3E),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Dia da Semana',
              labelStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: const Color(0xFF2C2C3E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
            items: DayOfWeek.values
                .where((day) => day != DayOfWeek.empty)
                .map((DayOfWeek day) {
              return DropdownMenuItem<DayOfWeek>(
                value: day,
                child: Text(_dayOfWeekToPortugueseString(day)),
              );
            }).toList(),
            onChanged: (DayOfWeek? newValue) {
              setState(() => _selectedDayOfWeek = newValue);
            },
          ),
          const SizedBox(height: 24),
          _buildMealsExpansionTile(),
        ],
      ),
    );
  }

  Widget _buildMealsExpansionTile() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        title: Text('Refeições (${_selectedMeals.length} selecionadas)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconColor: Colors.greenAccent,
        collapsedIconColor: Colors.white70,
        children: _availableMeals.isEmpty
            ? [const ListTile(title: Text("Nenhuma refeição encontrada.", style: TextStyle(color: Colors.white70)))]
            : _availableMeals.map((meal) {
                final isSelected = _selectedMeals.any((m) => m.id == meal.id);
                return CheckboxListTile(
                  title: Text(meal.name, style: const TextStyle(color: Colors.white)),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedMeals.add(meal);
                      } else {
                        _selectedMeals.removeWhere((m) => m.id == meal.id);
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
