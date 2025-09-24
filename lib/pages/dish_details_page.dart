import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/nutritionService/dish_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/food_dto.dart';
import 'package:shape_up_app/services/user_food_service.dart';
import 'package:shape_up_app/services/dish_service.dart';
import 'package:shape_up_app/services/authentication_service.dart';

import '../dtos/nutritionService/dish_ingredient_dto.dart';
import '../dtos/nutritionService/ingredient_input_dto.dart';

class DishDetailsPage extends StatefulWidget {
  final DishDto dish;

  const DishDetailsPage({super.key, required this.dish});

  @override
  State<DishDetailsPage> createState() => _DishDetailsPageState();
}

class _DishDetailsPageState extends State<DishDetailsPage> {
  late TextEditingController _dishNameController;
  late List<DishIngredientDto> _editableIngredients;
  List<FoodDto> _availableUserFoods = [];
  bool _isLoadingUserFoods = false;
  bool _isSaving = false;
  String? _loadingError;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _dishNameController = TextEditingController(text: widget.dish.name);
    _dishNameController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _editableIngredients = List<DishIngredientDto>.from(
        widget.dish.ingredients.map((ingredient) => ingredient.clone()));
    _loadUserFoods();
  }

  @override
  void dispose() {
    _dishNameController.removeListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _dishNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserFoods() async {
    if (_isLoadingUserFoods) return;
    setState(() {
      _isLoadingUserFoods = true;
      _loadingError = null;
    });
    try {
      final userId = await AuthenticationService.getProfileId();
      if (userId.isEmpty) {
        throw Exception("Usuário não autenticado.");
      }
      final foods = await UserFoodService.listUserFoods(userId: userId, rows: 1000);
      if (mounted) {
        setState(() {
          _availableUserFoods = foods;
          _isLoadingUserFoods = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar comidas do usuário: $e");
      if (mounted) {
        setState(() {
          _loadingError = "Erro ao carregar lista de comidas.";
          _isLoadingUserFoods = false;
        });
      }
    }
  }

  void _removeFoodFromDish(int index) {
    if (_isSaving) return;
    setState(() {
      _editableIngredients.removeAt(index);
    });
  }

  void _showAddFoodToDishDialog() {
    if (_isLoadingUserFoods) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Carregando sua lista de comidas...")),
      );
      return;
    }
    if (_loadingError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_loadingError!), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (_availableUserFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nenhuma comida encontrada na sua lista para adicionar.")),
      );
      return;
    }
    FoodDto? selectedFood;
    final quantityController = TextEditingController(text: "100.0");

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { 
        return StatefulBuilder(
          builder:(context, setDialogState){ 
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C3E),
              title: const Text('Adicionar Comida ao Prato', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<FoodDto>(
                    isExpanded: true,
                    value: selectedFood,
                    hint: const Text("Selecione uma comida", style: TextStyle(color: Colors.white70)),
                    dropdownColor: const Color(0xFF2A2A3D),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (FoodDto? newValue) {
                      setDialogState(() {
                        selectedFood = newValue;
                      });
                    },
                    items: _availableUserFoods.map<DropdownMenuItem<FoodDto>>((FoodDto food) {
                      return DropdownMenuItem<FoodDto>(
                        value: food,
                        child: Text(food.name ?? 'Comida sem nome'),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: quantityController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Quantidade (g)",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      suffixText: "g",
                      suffixStyle: const TextStyle(color: Colors.white70),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar', style: TextStyle(color: Colors.redAccent)),
                  onPressed: () => Navigator.of(dialogContext).pop(), 
                ),
                TextButton(
                  child: const Text('Adicionar', style: TextStyle(color: Colors.greenAccent)),
                  onPressed: () {
                    if (selectedFood != null) {
                      final quantity = double.tryParse(quantityController.text) ?? 100.0;
                      bool foodExists = _editableIngredients.any((ing) => ing.food.id == selectedFood!.id);
                      if (foodExists) {
                        ScaffoldMessenger.of(this.context).showSnackBar( 
                          SnackBar(
                            content: Text('"${selectedFood!.name ?? 'Esta comida'}" já está na lista de ingredientes.'),
                            backgroundColor: Colors.orangeAccent,
                          ),
                        );
                      } else {
                        setState(() { 
                           _editableIngredients.add(
                               DishIngredientDto(
                                   quantity: quantity, food: selectedFood!.clone()));
                        });
                        Navigator.of(dialogContext).pop(); 
                      }
                    } else {
                      ScaffoldMessenger.of(this.context).showSnackBar( 
                        const SnackBar(content: Text('Por favor, selecione uma comida.'), backgroundColor: Colors.orangeAccent),
                      );
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_editableIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O prato não pode ficar sem ingredientes.'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }
    setState(() {
      _isSaving = true;
    });

    final updatedDishName = _dishNameController.text;
    final ingredientInputList = _editableIngredients.map((ingredient) {
      return IngredientInputDto(
        foodId: ingredient.food.id,
        quantity: ingredient.quantity,
      );
    }).toList();
    print('DishDetailsPage._saveChanges: ingredientInputList a ser enviada (${ingredientInputList.length} IDs):'); // <<< NOVO LOG
    for (var dto in ingredientInputList) {
      print('  Food ID: ${dto.foodId}, Quantidade: ${dto.quantity}');
    }
    try {
      await DishService.updateDish(
        widget.dish.id,
        name: updatedDishName, 
        ingredients: ingredientInputList,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prato "$updatedDishName" atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); 
      }
    } catch (e) {
      print("Erro ao atualizar prato: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar prato: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("--- LOG BUILD (DishDetailsPage.dart) ---");
    print("Prato recebido ID: ${widget.dish.id}, Nome: ${widget.dish.name}");
    for (var ingredient in widget.dish.ingredients) {
      print("  -> Ingrediente RECEBIDO Food ID: ${ingredient.food.id}, Nome: ${ingredient.food.name}");
    }
    print("--- FIM LOG BUILD ---");
    return Scaffold(
      appBar: AppBar(
        title: Text(_dishNameController.text.isNotEmpty ? _dishNameController.text : widget.dish.name, style: TextStyle(color: _isSaving ? Colors.grey : Colors.white)),
        backgroundColor: const Color(0xFF101827),
        iconTheme: IconThemeData(color: _isSaving ? Colors.grey : Colors.white),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChanges,
              tooltip: 'Salvar Alterações',
            ),
        ],
      ),
      backgroundColor: const Color(0xFF1C1C2E),
      body: Form( 
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _dishNameController,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Nome do Prato',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[700]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.greenAccent)),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome para o prato.';
                  }
                  return null;
                },
                readOnly: _isSaving,
              ),
              const SizedBox(height: 20),
              const Text(
                'Ingredientes:', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              if (_editableIngredients.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'Nenhum ingrediente. Adicione comidas ao prato.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 16),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _editableIngredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = _editableIngredients[index];
                      final food = ingredient.food;

                      return Card(
                        color: const Color(0xFF2A2A3D),
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          title: Text(food.name ?? 'Nome indisponível', style: TextStyle(color: _isSaving ? Colors.grey : Colors.white, fontWeight: FontWeight.w600)),
                          subtitle: Text(food.brand ?? 'Marca não informada', style: TextStyle(color: _isSaving ? Colors.grey[700] : Colors.white70)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${ingredient.quantity.toStringAsFixed(1)} g",
                                style: TextStyle(color: _isSaving ? Colors.grey[700] : Colors.white70, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline, color: _isSaving ? Colors.grey : Colors.redAccent),
                                onPressed: _isSaving ? null : () => _removeFoodFromDish(index),
                                tooltip: 'Remover ${food.name ?? 'comida'}',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isSaving ? null : _showAddFoodToDishDialog,
        backgroundColor: _isSaving ? Colors.grey : Colors.greenAccent,
        tooltip: 'Adicionar Comida',
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
