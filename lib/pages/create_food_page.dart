
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shape_up_app/dtos/nutritionService/nutritional_info_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/macronutrients_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/carbohydrates_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/fats_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/micronutrient_details_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/sugar_details_dto.dart';
import 'package:shape_up_app/services/user_food_service.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/pages/barcode_scanner_page.dart';

// Classe auxiliar para controladores de campos de micronutrientes
class _MicronutrientFormFieldControllers {
  final String id = UniqueKey().toString();
  TextEditingController nameController;
  TextEditingController quantityController;
  TextEditingController unitController;

  _MicronutrientFormFieldControllers({
    required String name,
    required String quantity,
    required String unit,
  })  : nameController = TextEditingController(text: name),
        quantityController = TextEditingController(text: quantity),
        unitController = TextEditingController(text: unit);

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
  }
}


class CreateFoodPage extends StatefulWidget {
  const CreateFoodPage({super.key});

  @override
  State<CreateFoodPage> createState() => _CreateFoodPageState();
}

class _CreateFoodPageState extends State<CreateFoodPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _barCodeController;
  late TextEditingController _servingSizeController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinsController;
  late TextEditingController _carbsTotalController;
  late TextEditingController _carbsDietaryFiberController;
  late TextEditingController _carbsSugarTotalController;
  late TextEditingController _carbsSugarAddedController;
  late TextEditingController _carbsSugarAlcoholsController;
  late TextEditingController _fatsTotalController;
  late TextEditingController _fatsSaturatedController;
  late TextEditingController _fatsTransController;
  late TextEditingController _fatsPolyunsaturatedController;
  late TextEditingController _fatsMonounsaturatedController;
  late TextEditingController _fatsCholesterolController;

  List<_MicronutrientFormFieldControllers> _micronutrientFormFields = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _brandController = TextEditingController();
    _barCodeController = TextEditingController();
    _servingSizeController = TextEditingController(text: '100.0'); // Default
    _caloriesController = TextEditingController();
    _proteinsController = TextEditingController();
    _carbsTotalController = TextEditingController();
    _carbsDietaryFiberController = TextEditingController();
    _carbsSugarTotalController = TextEditingController();
    _carbsSugarAddedController = TextEditingController();
    _carbsSugarAlcoholsController = TextEditingController();
    _fatsTotalController = TextEditingController();
    _fatsSaturatedController = TextEditingController();
    _fatsTransController = TextEditingController();
    _fatsPolyunsaturatedController = TextEditingController();
    _fatsMonounsaturatedController = TextEditingController();
    _fatsCholesterolController = TextEditingController();

    for (var controllerGroup in _micronutrientFormFields) {
      controllerGroup.dispose();
    }
    _micronutrientFormFields = [];
  }
  Future<void> _scanBarcode() async {
    if (_isSaving) return;

    // Navega para a página do scanner e aguarda um resultado (o código)
    final String? barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerPage()),
    );

    // Se um código for retornado e a tela ainda estiver "montada",
    // atualiza o campo de texto.
    if (barcode != null && barcode.isNotEmpty && mounted) {
      setState(() {
        _barCodeController.text = barcode;
      });
    }
  }

  void _addMicronutrientField() {
    setState(() {
      _micronutrientFormFields.add(_MicronutrientFormFieldControllers(
        name: '',
        quantity: '',
        unit: '',
      ));
    });
  }

  void _removeMicronutrientField(String id) {
    setState(() {
      final fieldIndex = _micronutrientFormFields.indexWhere((field) => field.id == id);
      if (fieldIndex != -1) {
        _micronutrientFormFields[fieldIndex].dispose();
        _micronutrientFormFields.removeAt(fieldIndex);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _barCodeController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbsTotalController.dispose();
    _carbsDietaryFiberController.dispose();
    _carbsSugarTotalController.dispose();
    _carbsSugarAddedController.dispose();
    _carbsSugarAlcoholsController.dispose();
    _fatsTotalController.dispose();
    _fatsSaturatedController.dispose();
    _fatsTransController.dispose();
    _fatsPolyunsaturatedController.dispose();
    _fatsMonounsaturatedController.dispose();
    _fatsCholesterolController.dispose();
    for (var controllerGroup in _micronutrientFormFields) {
      controllerGroup.dispose();
    }
    super.dispose();
  }

  Future<void> _onCreate() async {
    if (_isSaving) return;

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final String userId = await AuthenticationService.getProfileId(); // Obter userId
      if (userId.isEmpty && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro: Usuário não identificado. Tente novamente.')));
         setState(() {
           _isSaving = false;
         });
         return;
      }

      final name = _nameController.text;
      final brand = _brandController.text.isNotEmpty ? _brandController.text : null;
      final barCode = _barCodeController.text.isNotEmpty ? _barCodeController.text : null;
      
      final servingSize = double.tryParse(_servingSizeController.text) ?? 100.0;
      final calories = double.tryParse(_caloriesController.text);
      final proteins = double.tryParse(_proteinsController.text);
      
      final carbsTotal = double.tryParse(_carbsTotalController.text);
      final carbsDietaryFiber = double.tryParse(_carbsDietaryFiberController.text);
      final carbsSugarTotal = double.tryParse(_carbsSugarTotalController.text);
      final carbsSugarAdded = double.tryParse(_carbsSugarAddedController.text);
      final carbsSugarAlcohols = double.tryParse(_carbsSugarAlcoholsController.text);

      final fatsTotal = double.tryParse(_fatsTotalController.text);
      final fatsSaturated = double.tryParse(_fatsSaturatedController.text);
      final fatsTrans = double.tryParse(_fatsTransController.text);
      final fatsPolyunsaturated = double.tryParse(_fatsPolyunsaturatedController.text);
      final fatsMonounsaturated = double.tryParse(_fatsMonounsaturatedController.text);
      final fatsCholesterol = double.tryParse(_fatsCholesterolController.text);

      CarbohydratesDto? carbohydratesDto;
      if (carbsTotal != null || carbsDietaryFiber != null || carbsSugarTotal != null || carbsSugarAdded != null || carbsSugarAlcohols != null) {
        SugarDetailsDto? sugarDetailsDto;
        if (carbsSugarTotal != null || carbsSugarAdded != null || carbsSugarAlcohols != null) {
          sugarDetailsDto = SugarDetailsDto(
            total: carbsSugarTotal ?? 0.0,
            addedSugar: carbsSugarAdded,
            sugarAlcohols: carbsSugarAlcohols,
          );
        }
        carbohydratesDto = CarbohydratesDto(
          total: carbsTotal ?? 0.0,
          dietaryFiber: carbsDietaryFiber,
          sugar: sugarDetailsDto,
        );
      }

      FatsDto? fatsDto;
      if (fatsTotal != null || fatsSaturated != null || fatsTrans != null || fatsPolyunsaturated != null || fatsMonounsaturated != null || fatsCholesterol != null) {
        fatsDto = FatsDto(
          total: fatsTotal ?? 0.0,
          saturatedFat: fatsSaturated,
          transFat: fatsTrans,
          polyunsaturatedFat: fatsPolyunsaturated,
          monounsaturatedFat: fatsMonounsaturated,
          cholesterol: fatsCholesterol,
        );
      }
      
      MacronutrientsDto? macronutrientsDto;
      if (proteins != null || carbohydratesDto != null || fatsDto != null) {
          macronutrientsDto = MacronutrientsDto(
          proteins: proteins,
          carbohydrates: carbohydratesDto,
          fats: fatsDto,
        );
      }

      Map<String, MicronutrientDetailsDto> micronutrientsMap = {};
      for (var fieldControllers in _micronutrientFormFields) {
        final microName = fieldControllers.nameController.text.trim();
        final microQuantityStr = fieldControllers.quantityController.text.trim();
        final microUnit = fieldControllers.unitController.text.trim();

        if (microName.isNotEmpty && microQuantityStr.isNotEmpty) {
          final microQuantity = double.tryParse(microQuantityStr);
          if (microQuantity != null) {
            micronutrientsMap[microName] = MicronutrientDetailsDto(
              quantity: microQuantity,
              unit: microUnit.isNotEmpty ? microUnit : '-', 
            );
          }
        }
      }

      final nutritionalInfo = NutritionalInfoDto(
        servingSize: servingSize,
        calories: calories,
        macronutrients: macronutrientsDto,
        micronutrients: micronutrientsMap.isNotEmpty ? micronutrientsMap : null,
      );

      try {
        await UserFoodService.createUserFood(
          userId: userId, // Passar userId
          name: name,
          brand: brand,
          barCode: barCode,
          nutritionalInfo: nutritionalInfo,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comida criada com sucesso!')));
          Navigator.pop(context, true); 
        }
      } catch (e) {
        print("Erro ao criar comida: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar comida: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, corrija os erros no formulário.')),
      );
    }
  }
  
  String? _validateNumericField(String? value, {bool isRequired = false, bool allowZero = true, bool allowNegative = false, String fieldName = 'Campo'}) {
    if (value == null || value.isEmpty) {
      return isRequired ? '$fieldName é obrigatório' : null;
    }
    final number = double.tryParse(value);
    if (number == null) {
      return 'Valor inválido para $fieldName';
    }
    if (!allowZero && number == 0) {
      return '$fieldName não pode ser zero';
    }
    if (!allowNegative && number < 0) {
      return '$fieldName não pode ser negativo';
    }
    return null;
  }

  Widget _buildDetailRow(String label, {required TextEditingController controller, bool isNumeric = false, bool isLastField = false, String? Function(String?)? customValidator, Widget? suffixIcon,}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              readOnly: _isSaving,
              style: TextStyle(color: _isSaving ? Colors.grey[600] : Colors.white, fontSize: 16),
              keyboardType: isNumeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
              inputFormatters: isNumeric ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]*'))] : [],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withOpacity(0.1),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[700]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _isSaving ? Colors.grey[700]! : Colors.blueAccent)),
                errorStyle: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w500),
                errorMaxLines: 2,
                suffixIcon: suffixIcon,
              ),
              textAlign: TextAlign.end,
              textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
              validator: customValidator,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicronutrientsEditSection() {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _micronutrientFormFields.length,
          itemBuilder: (context, index) {
            final fieldSet = _micronutrientFormFields[index];
            return Card(
              key: ValueKey(fieldSet.id),
              color: Colors.black.withOpacity(0.15),
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: fieldSet.nameController,
                            readOnly: _isSaving,
                            style: TextStyle(color: _isSaving ? Colors.grey[600] : Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Micronutriente',
                              labelStyle: TextStyle(color: Colors.grey[400]),
                              isDense: true,
                              filled: true, fillColor: Colors.black.withOpacity(0.1),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: _isSaving ? Colors.grey[700]! : Colors.blueAccent)),
                              errorStyle: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w500),
                            ),
                            validator: (value) {
                              if (fieldSet.quantityController.text.isNotEmpty || fieldSet.unitController.text.isNotEmpty) {
                                if (value == null || value.isEmpty) {
                                  return 'Nome obrigatório se Qtd/Unidade preenchidos';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        if (!_isSaving)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                            onPressed: () => _removeMicronutrientField(fieldSet.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: fieldSet.quantityController,
                            readOnly: _isSaving,
                            style: TextStyle(color: _isSaving ? Colors.grey[600] : Colors.white, fontSize: 15),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]*'))],
                            decoration: InputDecoration(
                              labelText: 'Quantidade',
                              labelStyle: TextStyle(color: Colors.grey[400]),
                              isDense: true,
                              filled: true, fillColor: Colors.black.withOpacity(0.1),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: _isSaving ? Colors.grey[700]! : Colors.blueAccent)),
                              errorStyle: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w500),
                            ),
                            validator: (value) {
                              final baseValidation = _validateNumericField(value, fieldName: 'Qtd.', allowNegative: false, isRequired: fieldSet.nameController.text.isNotEmpty);
                              if (baseValidation != null) return baseValidation;
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: fieldSet.unitController,
                            readOnly: _isSaving,
                            style: TextStyle(color: _isSaving ? Colors.grey[600] : Colors.white, fontSize: 15),
                            decoration: InputDecoration(
                              labelText: 'Unidade',
                              labelStyle: TextStyle(color: Colors.grey[400]),
                              isDense: true,
                              filled: true, fillColor: Colors.black.withOpacity(0.1),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: _isSaving ? Colors.grey[700]! : Colors.blueAccent))
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (!_isSaving)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton.icon(
              icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
              label: const Text('Adicionar Micronutriente', style: TextStyle(color: Colors.blueAccent)),
              onPressed: _addMicronutrientField,
            ),
          ),
      ],
    );
  }

  Widget _buildNutrientCard(String title, List<Widget> fields, {Widget? dynamicSection}) {
    return Card(
      color: const Color(0xFF2A2A3D),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...fields,
            if (dynamicSection != null) ...[
              const Divider(color: Colors.white24, height: 20, thickness: 0.5),
              dynamicSection
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar Nova Comida", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF101827),
        iconTheme: IconThemeData(color: _isSaving ? Colors.grey : Colors.white),
        actions: [
          _isSaving
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
              )
            : IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                onPressed: _onCreate,
              )
        ],
      ),
      body: SafeArea(child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildNutrientCard('Informações Gerais', [
                _buildDetailRow('Nome', controller: _nameController, customValidator: (value) {
                  if (value == null || value.isEmpty) return 'Nome é obrigatório';
                  return null;
                }),
                _buildDetailRow('Marca (Opcional)', controller: _brandController),
                _buildDetailRow(
                  'Cód. Barras (Opcional)',
                  controller: _barCodeController,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.qr_code_scanner_rounded, color: _isSaving ? Colors.grey : Colors.blueAccent),
                    onPressed: _isSaving ? null : _scanBarcode,
                  ),
                ),
                _buildDetailRow('Porção (g)', controller: _servingSizeController, isNumeric: true, customValidator: (value) => _validateNumericField(value, fieldName: 'Porção', isRequired: true, allowZero: false, allowNegative: false)),
                _buildDetailRow('Calorias (kcal)', controller: _caloriesController, isNumeric: true, customValidator: (value) => _validateNumericField(value, fieldName: 'Calorias', allowNegative: false)),
              ]),

              _buildNutrientCard('Macronutrientes (por porção)', [
                _buildDetailRow('Proteínas (g)', controller: _proteinsController, isNumeric: true, customValidator: (value) => _validateNumericField(value, fieldName: 'Proteínas', allowNegative: false)),
                _buildDetailRow('Carb. Totais (g)', controller: _carbsTotalController, isNumeric: true, customValidator: (value) {
                  final validation = _validateNumericField(value, fieldName: 'Carb. Totais', allowNegative: false,
                      isRequired: _carbsDietaryFiberController.text.isNotEmpty || _carbsSugarTotalController.text.isNotEmpty);
                  if (validation != null) return validation;
                  return null;
                }),
                _buildDetailRow('  Fibra (g)', controller: _carbsDietaryFiberController, isNumeric: true, customValidator: (value) {
                  final validation = _validateNumericField(value, fieldName: 'Fibra', allowNegative: false);
                  if (validation != null) return validation;
                  final totalCarbs = double.tryParse(_carbsTotalController.text);
                  final fiber = double.tryParse(value ?? "");
                  if (totalCarbs != null && fiber != null && fiber > totalCarbs) {
                    return 'Fibra > Carb. Totais';
                  }
                  return null;
                }),
                _buildDetailRow('  Açúc. Totais (g)', controller: _carbsSugarTotalController, isNumeric: true, customValidator: (value) {
                  final validation = _validateNumericField(value, fieldName: 'Açúc. Totais', allowNegative: false,
                      isRequired: _carbsSugarAddedController.text.isNotEmpty || _carbsSugarAlcoholsController.text.isNotEmpty);
                  if (validation != null) return validation;
                  final totalCarbs = double.tryParse(_carbsTotalController.text);
                  final sugarTotal = double.tryParse(value ?? "");
                  if (totalCarbs != null && sugarTotal != null && sugarTotal > totalCarbs) {
                    return 'Açúc. Totais > Carb. Totais';
                  }
                  return null;
                }),
                _buildDetailRow('    Adicion. (g)', controller: _carbsSugarAddedController, isNumeric: true, customValidator: (value) {
                  final validation = _validateNumericField(value, fieldName: 'Açúc. Adic.', allowNegative: false);
                  if (validation != null) return validation;
                  final totalSugar = double.tryParse(_carbsSugarTotalController.text);
                  final addedSugar = double.tryParse(value ?? "");
                  if (totalSugar != null && addedSugar != null && addedSugar > totalSugar) {
                    return 'Adicion. > Açúc. Totais';
                  }
                  return null;
                }),
                _buildDetailRow('    Polióis (g)', controller: _carbsSugarAlcoholsController, isNumeric: true, customValidator: (value) => _validateNumericField(value, fieldName: 'Polióis', allowNegative: false)),
                _buildDetailRow('Gord. Totais (g)', controller: _fatsTotalController, isNumeric: true, customValidator: (value) {
                  return _validateNumericField(value, fieldName: 'Gord. Totais', allowNegative: false,
                      isRequired: _fatsSaturatedController.text.isNotEmpty || _fatsTransController.text.isNotEmpty || _fatsPolyunsaturatedController.text.isNotEmpty || _fatsMonounsaturatedController.text.isNotEmpty);
                }),
                _buildDetailRow('  Saturadas (g)', controller: _fatsSaturatedController, isNumeric: true, customValidator: (value) {
                  final validation = _validateNumericField(value, fieldName: 'Saturadas', allowNegative: false);
                  if (validation != null) return validation;
                  final totalFats = double.tryParse(_fatsTotalController.text);
                  final saturated = double.tryParse(value ?? "");
                  if (totalFats != null && saturated != null && saturated > totalFats) {
                    return 'Saturadas > Gord. Totais';
                  }
                  return null;
                }),
                _buildDetailRow('  Trans (g)', controller: _fatsTransController, isNumeric: true, customValidator: (value) {
                  final validation = _validateNumericField(value, fieldName: 'Trans', allowNegative: false);
                  if (validation != null) return validation;
                  final totalFats = double.tryParse(_fatsTotalController.text);
                  final trans = double.tryParse(value ?? "");
                  if (totalFats != null && trans != null && trans > totalFats) {
                    return 'Trans > Gord. Totais';
                  }
                  return null;
                }),
                _buildDetailRow('  Poli-insat. (g)', controller: _fatsPolyunsaturatedController, isNumeric: true, customValidator: (value) {
                  final validation = _validateNumericField(value, fieldName: 'Poli-insat.', allowNegative: false);
                  if (validation != null) return validation;
                  final totalFats = double.tryParse(_fatsTotalController.text);
                  final poly = double.tryParse(value ?? "");
                  if (totalFats != null && poly != null && poly > totalFats) {
                    return 'Poli-insat. > Gord. Totais';
                  }
                  return null;
                }),
                _buildDetailRow('  Monoinsat. (g)', controller: _fatsMonounsaturatedController, isNumeric: true, customValidator: (value) {
                  final validation = _validateNumericField(value, fieldName: 'Monoinsat.', allowNegative: false);
                  if (validation != null) return validation;
                  final totalFats = double.tryParse(_fatsTotalController.text);
                  final mono = double.tryParse(value ?? "");
                  if (totalFats != null && mono != null && mono > totalFats) {
                    return 'Monoinsat. > Gord. Totais';
                  }
                  return null;
                }),
                _buildDetailRow('  Colesterol (mg)', controller: _fatsCholesterolController, isNumeric: true, isLastField: true, customValidator: (value) => _validateNumericField(value, fieldName: 'Colesterol', allowNegative: false)),
              ]),

              _buildNutrientCard(
                'Micronutrientes (por porção)',
                [],
                dynamicSection: _buildMicronutrientsEditSection(),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.cancel_outlined, color: Colors.white70),
                      label: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                      onPressed: _isSaving ? null : () {
                        // TODO: Adicionar lógica de confirmação se houver alterações
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.add_circle_outline),
                      label: Text(_isSaving ? 'Criando...' : 'Criar Comida'),
                      onPressed: _isSaving ? null : _onCreate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaving ? Colors.grey[600] : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),)
    );
  }
}
