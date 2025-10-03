import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/nutritionService/food_dto.dart';
import 'package:shape_up_app/services/user_food_service.dart';
import 'package:shape_up_app/services/dish_service.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/dtos/nutritionService/dish_ingredient_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/ingredient_input_dto.dart';

class CreateDishPage extends StatefulWidget {
  const CreateDishPage({super.key});

  @override
  State<CreateDishPage> createState() => _CreateDishPageState();
}

class _CreateDishPageState extends State<CreateDishPage> {
  final _formKey = GlobalKey<FormState>();
  final _dishNameController = TextEditingController();

  final List<DishIngredientDto> _selectedIngredients = [];
  List<FoodDto> _availableUserFoods = [];
  
  bool _isLoadingUserFoods = true;
  bool _isSaving = false;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _loadUserFoods();
  }

  @override
  void dispose() {
    _dishNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserFoods() async {
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
      setState(() {
        _availableUserFoods = foods;
        _isLoadingUserFoods = false;
      });
    } catch (e) {
      print("Erro ao carregar comidas do usuário: $e");
      setState(() {
        _loadingError = "Erro ao carregar suas comidas. Tente novamente.";
        _isLoadingUserFoods = false;
      });
    }
  }

  void _addFoodToDish(FoodDto food, double quantity) {
    // Verifica se a comida já existe na lista antes de adicionar
    bool alreadyExists = _selectedIngredients.any((ingredient) => ingredient.food.id == food.id);
    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${food.name ?? 'Esta comida'}" já foi adicionada.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    setState(() {
      _selectedIngredients.add(DishIngredientDto(quantity: quantity, food: food));
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
      builder: (BuildContext dialogContext) { // Renomeado context para evitar conflito
        return StatefulBuilder( 
          builder: (context, setDialogState) {
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
                      return DropdownMenuItem<FoodDto>(value: food, child: Text(food.name ?? 'Comida sem nome'));
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
                  onPressed: () => Navigator.of(dialogContext).pop(), // Usa dialogContext
                ),
                TextButton(
                  child: const Text('Adicionar', style: TextStyle(color: Colors.blueAccent)),
                  onPressed: () {
                    if (selectedFood != null) {
                      final quantity = double.tryParse(quantityController.text) ?? 100.0;
                      // A verificação agora é feita dentro de _addFoodToDish
                      _addFoodToDish(selectedFood!, quantity); 
                                            
                      // Verifica se a comida foi realmente adicionada (não existia antes) para fechar o diálogo
                      bool wasAdded = _selectedIngredients.any((ing) => ing.food.id == selectedFood!.id);
                      if (wasAdded) { // Se foi adicionado (ou já estava lá e o usuário tentou adicionar de novo)
                        Navigator.of(dialogContext).pop(); // Usa dialogContext
                      }
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar( // Usa o context da página
                        const SnackBar(content: Text('Por favor, selecione uma comida.'), backgroundColor: Colors.orangeAccent),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeFoodFromDish(int index) {
    setState(() {
      _selectedIngredients.removeAt(index);
    });
  }

  Future<void> _onSaveDish() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma comida ao prato.'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final dishName = _dishNameController.text;
    final ingredientInputList = _selectedIngredients.map((ingredient) {
      return IngredientInputDto(
        foodId: ingredient.food.id,
        quantity: ingredient.quantity,
      );
    }).toList();

    try {
      await DishService.createDishForSameUser(
        name: dishName,
        ingredients: ingredientInputList,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prato "$dishName" criado com sucesso!'), backgroundColor: Colors.blue),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      print("Erro ao criar prato: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar prato: $e'), backgroundColor: Colors.redAccent),
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

  Widget _buildSelectedFoodsList() {
    if (_selectedIngredients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: Text('Nenhuma comida adicionada ao prato ainda.', style: TextStyle(color: Colors.white70))),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedIngredients.length,
      itemBuilder: (context, index) {
        final ingredient = _selectedIngredients[index];
        final food = ingredient.food;
        return Card(
          color: const Color(0xFF2A2A3D),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(food.name ?? 'Comida sem nome', style: const TextStyle(color: Colors.white)),
            subtitle: Text("Quantidade: ${ingredient.quantity}g", style: TextStyle(color: Colors.grey[400])),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle_outline, color: _isSaving ? Colors.grey : Colors.redAccent),
              onPressed: _isSaving ? null : () => _removeFoodFromDish(index),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101827),
      appBar: AppBar(
        title: const Text('Criar Novo Prato', style: TextStyle(color: Colors.white)),
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
              onPressed: _onSaveDish,
              tooltip: 'Salvar Prato',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _dishNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nome do Prato',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[700]!)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.blueAccent)),
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
              ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Adicionar Comida ao Prato'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isSaving ? null : _showAddFoodToDishDialog,
              ),
              const SizedBox(height: 20),
              Text(
                'Comidas no Prato (${_selectedIngredients.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              _buildSelectedFoodsList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
