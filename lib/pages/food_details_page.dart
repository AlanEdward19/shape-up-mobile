
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:shape_up_app/dtos/nutritionService/food_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/nutritional_info_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/macronutrients_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/carbohydrates_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/fats_dto.dart';
import 'package:shape_up_app/dtos/nutritionService/micronutrient_details_dto.dart';
import 'package:shape_up_app/services/user_food_service.dart';

import '../dtos/nutritionService/sugar_details_dto.dart';

// Classe auxiliar para controladores de campos de micronutrientes
class _MicronutrientFormFieldControllers {
  final String id = UniqueKey().toString(); // Para keys de widget
  TextEditingController nameController;
  TextEditingController quantityController;
  TextEditingController unitController;
  bool isNew; // Marca se é uma nova entrada adicionada pelo usuário

  _MicronutrientFormFieldControllers({
    required String name,
    required String quantity,
    required String unit,
    this.isNew = false,
  })  : nameController = TextEditingController(text: name),
        quantityController = TextEditingController(text: quantity),
        unitController = TextEditingController(text: unit);

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
  }
}

class FoodDetailsPage extends StatefulWidget {
  final FoodDto food;

  const FoodDetailsPage({super.key, required this.food});

  @override
  State<FoodDetailsPage> createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;
  bool _isSaving = false; 
  late FoodDto _editableFoodData;

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
    _initializeEditableDataAndControllers(widget.food);
  }

  void _initializeEditableDataAndControllers(FoodDto sourceFood) {
    _editableFoodData = sourceFood.clone();
    _nameController = TextEditingController(text: _editableFoodData.name);
    _brandController = TextEditingController(text: _editableFoodData.brand ?? '');
    _barCodeController = TextEditingController(text: _editableFoodData.barCode ?? '');
    final nutritionalInfo = _editableFoodData.nutritionalInfo;
    _servingSizeController = TextEditingController(text: nutritionalInfo.servingSize.toStringAsFixed(1));
    _caloriesController = TextEditingController(text: nutritionalInfo.calories?.toStringAsFixed(1) ?? '');
    final macronutrients = nutritionalInfo.macronutrients;
    _proteinsController = TextEditingController(text: macronutrients?.proteins?.toStringAsFixed(1) ?? '');
    _carbsTotalController = TextEditingController(text: macronutrients?.carbohydrates?.total.toStringAsFixed(1) ?? '');
    _carbsDietaryFiberController = TextEditingController(text: macronutrients?.carbohydrates?.dietaryFiber?.toStringAsFixed(1) ?? '');
    _carbsSugarTotalController = TextEditingController(text: macronutrients?.carbohydrates?.sugar?.total.toStringAsFixed(1) ?? '');
    _carbsSugarAddedController = TextEditingController(text: macronutrients?.carbohydrates?.sugar?.addedSugar?.toStringAsFixed(1) ?? '');
    _carbsSugarAlcoholsController = TextEditingController(text: macronutrients?.carbohydrates?.sugar?.sugarAlcohols?.toStringAsFixed(1) ?? '');
    _fatsTotalController = TextEditingController(text: macronutrients?.fats?.total.toStringAsFixed(1) ?? '');
    _fatsSaturatedController = TextEditingController(text: macronutrients?.fats?.saturatedFat?.toStringAsFixed(1) ?? '');
    _fatsTransController = TextEditingController(text: macronutrients?.fats?.transFat?.toStringAsFixed(1) ?? '');
    _fatsPolyunsaturatedController = TextEditingController(text: macronutrients?.fats?.polyunsaturatedFat?.toStringAsFixed(1) ?? '');
    _fatsMonounsaturatedController = TextEditingController(text: macronutrients?.fats?.monounsaturatedFat?.toStringAsFixed(1) ?? '');
    _fatsCholesterolController = TextEditingController(text: macronutrients?.fats?.cholesterol?.toStringAsFixed(1) ?? '');

    for (var controllerGroup in _micronutrientFormFields) {
      controllerGroup.dispose();
    }
    _micronutrientFormFields = [];
    if (nutritionalInfo.micronutrients != null) {
      nutritionalInfo.micronutrients!.forEach((name, details) {
        _micronutrientFormFields.add(_MicronutrientFormFieldControllers(
          name: name,
          quantity: details.quantity.toStringAsFixed(2),
          unit: details.unit,
        ));
      });
    }
  }

  void _addMicronutrientField() {
    setState(() {
      _micronutrientFormFields.add(_MicronutrientFormFieldControllers(
        name: '',
        quantity: '',
        unit: '',
        isNew: true,
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

  void _toggleEditMode() {
    if (_isSaving) return; 
    setState(() {
      _isEditMode = !_isEditMode;
      if (_isEditMode) {
        _initializeEditableDataAndControllers(widget.food);
      }
    });
  }

  Future<void> _onSave() async {
    if (_isSaving) return; 

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final newName = _nameController.text;
      final newBrand = _brandController.text.isNotEmpty ? _brandController.text : null;
      final newBarCode = _barCodeController.text.isNotEmpty ? _barCodeController.text : null;

      MacronutrientsDto? updatedMacronutrients = _editableFoodData.nutritionalInfo.macronutrients?.clone();
      if (updatedMacronutrients != null) {
        updatedMacronutrients = MacronutrientsDto(
          proteins: double.tryParse(_proteinsController.text),
          carbohydrates: updatedMacronutrients.carbohydrates?.clone() != null || 
                         (_carbsTotalController.text.isNotEmpty || 
                          _carbsDietaryFiberController.text.isNotEmpty || 
                          _carbsSugarTotalController.text.isNotEmpty || 
                          _carbsSugarAddedController.text.isNotEmpty || 
                          _carbsSugarAlcoholsController.text.isNotEmpty)
            ? CarbohydratesDto(
                total: double.tryParse(_carbsTotalController.text) ?? 0.0,
                dietaryFiber: double.tryParse(_carbsDietaryFiberController.text),
                sugar: (updatedMacronutrients.carbohydrates?.sugar?.clone() != null || 
                         double.tryParse(_carbsSugarTotalController.text) != null || 
                         double.tryParse(_carbsSugarAddedController.text) != null || 
                         double.tryParse(_carbsSugarAlcoholsController.text) != null)
                  ? SugarDetailsDto(
                      total: double.tryParse(_carbsSugarTotalController.text) ?? 0.0,
                      addedSugar: double.tryParse(_carbsSugarAddedController.text),
                      sugarAlcohols: double.tryParse(_carbsSugarAlcoholsController.text),
                    )
                  : null,
              )
            : null,
          fats: updatedMacronutrients.fats?.clone() != null ||
                (_fatsTotalController.text.isNotEmpty ||
                 _fatsSaturatedController.text.isNotEmpty ||
                 _fatsTransController.text.isNotEmpty ||
                 _fatsPolyunsaturatedController.text.isNotEmpty ||
                 _fatsMonounsaturatedController.text.isNotEmpty ||
                 _fatsCholesterolController.text.isNotEmpty)
            ? FatsDto(
                total: double.tryParse(_fatsTotalController.text) ?? 0.0,
                saturatedFat: double.tryParse(_fatsSaturatedController.text),
                transFat: double.tryParse(_fatsTransController.text),
                polyunsaturatedFat: double.tryParse(_fatsPolyunsaturatedController.text),
                monounsaturatedFat: double.tryParse(_fatsMonounsaturatedController.text),
                cholesterol: double.tryParse(_fatsCholesterolController.text),
              )
            : null,
        );
      }
      
      Map<String, MicronutrientDetailsDto> updatedMicronutrientsMap = {};
      for (var fieldControllers in _micronutrientFormFields) {
        final microName = fieldControllers.nameController.text.trim();
        final microQuantityStr = fieldControllers.quantityController.text.trim();
        final microUnit = fieldControllers.unitController.text.trim();

        if (microName.isNotEmpty && microQuantityStr.isNotEmpty) {
          final microQuantity = double.tryParse(microQuantityStr);
          if (microQuantity != null) {
            updatedMicronutrientsMap[microName] = MicronutrientDetailsDto(
              quantity: microQuantity,
              unit: microUnit.isNotEmpty ? microUnit : '-',
            );
          }
        }
      }

      final updatedNutritionalInfo = _editableFoodData.nutritionalInfo.clone();
      final newNutritionalInfo = NutritionalInfoDto(
        servingSize: double.tryParse(_servingSizeController.text) ?? _editableFoodData.nutritionalInfo.servingSize,
        calories: double.tryParse(_caloriesController.text),
        macronutrients: updatedMacronutrients, 
        micronutrients: updatedMicronutrientsMap.isNotEmpty ? updatedMicronutrientsMap : null,
      );

      _editableFoodData = FoodDto(
        id: _editableFoodData.id,
        createdBy: _editableFoodData.createdBy,
        userId: _editableFoodData.userId,
        name: newName,
        brand: newBrand,
        barCode: newBarCode,
        isRevised: _editableFoodData.isRevised,
        nutritionalInfo: newNutritionalInfo,
      );

      try {
        await UserFoodService.editUserFood(
          _editableFoodData.id,
          name: _editableFoodData.name,
          brand: _editableFoodData.brand,
          barCode: _editableFoodData.barCode,
          nutritionalInfo: _editableFoodData.nutritionalInfo,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comida atualizada com sucesso!')));
          Navigator.pop(context, true);
          setState(() { _isEditMode = false; }); 
        }
      } catch (e) {
        print("Erro ao salvar comida: $e");
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
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

  bool _wereChangesMade() {
    if (!_isEditMode) return false;
    if (_nameController.text != widget.food.name) return true;
    if ((_brandController.text.isEmpty ? null : _brandController.text) != widget.food.brand) return true;
    if ((_barCodeController.text.isEmpty ? null : _barCodeController.text) != widget.food.barCode) return true;
    final originalNutritionalInfo = widget.food.nutritionalInfo;
    if (double.tryParse(_servingSizeController.text)?.toStringAsFixed(1) != originalNutritionalInfo.servingSize.toStringAsFixed(1)) return true;
    if (double.tryParse(_caloriesController.text)?.toStringAsFixed(1) != originalNutritionalInfo.calories?.toStringAsFixed(1)) return true;
    final originalMacronutrients = originalNutritionalInfo.macronutrients;
    if (double.tryParse(_proteinsController.text)?.toStringAsFixed(1) != originalMacronutrients?.proteins?.toStringAsFixed(1)) return true;
    final originalCarbs = originalMacronutrients?.carbohydrates;
    if (double.tryParse(_carbsTotalController.text)?.toStringAsFixed(1) != originalCarbs?.total.toStringAsFixed(1)) return true;
    if (double.tryParse(_carbsDietaryFiberController.text)?.toStringAsFixed(1) != originalCarbs?.dietaryFiber?.toStringAsFixed(1)) return true;
    final originalSugar = originalCarbs?.sugar;
    if (double.tryParse(_carbsSugarTotalController.text)?.toStringAsFixed(1) != originalSugar?.total.toStringAsFixed(1)) return true;
    if (double.tryParse(_carbsSugarAddedController.text)?.toStringAsFixed(1) != originalSugar?.addedSugar?.toStringAsFixed(1)) return true;
    if (double.tryParse(_carbsSugarAlcoholsController.text)?.toStringAsFixed(1) != originalSugar?.sugarAlcohols?.toStringAsFixed(1)) return true;
    final originalFats = originalMacronutrients?.fats;
    if (double.tryParse(_fatsTotalController.text)?.toStringAsFixed(1) != originalFats?.total.toStringAsFixed(1)) return true;
    if (double.tryParse(_fatsSaturatedController.text)?.toStringAsFixed(1) != originalFats?.saturatedFat?.toStringAsFixed(1)) return true;
    if (double.tryParse(_fatsTransController.text)?.toStringAsFixed(1) != originalFats?.transFat?.toStringAsFixed(1)) return true;
    if (double.tryParse(_fatsPolyunsaturatedController.text)?.toStringAsFixed(1) != originalFats?.polyunsaturatedFat?.toStringAsFixed(1)) return true;
    if (double.tryParse(_fatsMonounsaturatedController.text)?.toStringAsFixed(1) != originalFats?.monounsaturatedFat?.toStringAsFixed(1)) return true;
    if (double.tryParse(_fatsCholesterolController.text)?.toStringAsFixed(1) != originalFats?.cholesterol?.toStringAsFixed(1)) return true;

    final currentMicrosMap = <String, MicronutrientDetailsDto>{};
    for (var field in _micronutrientFormFields) {
      final name = field.nameController.text.trim();
      final qty = double.tryParse(field.quantityController.text.trim());
      final unit = field.unitController.text.trim();
      if (name.isNotEmpty && qty != null) {
        currentMicrosMap[name] = MicronutrientDetailsDto(quantity: qty, unit: unit.isNotEmpty ? unit : '-');
      }
    }
    final originalMicros = originalNutritionalInfo.micronutrients ?? {};
    if (currentMicrosMap.length != originalMicros.length) return true;
    for (var key in originalMicros.keys) {
      if (!currentMicrosMap.containsKey(key) || 
          currentMicrosMap[key]!.quantity.toStringAsFixed(2) != originalMicros[key]!.quantity.toStringAsFixed(2) ||
          currentMicrosMap[key]!.unit != originalMicros[key]!.unit) return true;
    }
    for (var key in currentMicrosMap.keys) {
        if (!originalMicros.containsKey(key)) return true;
    }
    return false;
  }

  Future<void> _showCancelConfirmationDialog() async {
    final bool? discardChanges = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C3E),
          title: const Text('Descartar Alterações?', style: TextStyle(color: Colors.white)),
          content: const Text('Você tem alterações não salvas. Tem certeza de que deseja descartá-las?', style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              child: const Text('Não', style: TextStyle(color: Colors.greenAccent)),
              onPressed: () { Navigator.of(context).pop(false); },
            ),
            TextButton(
              child: const Text('Sim, Descartar', style: TextStyle(color: Colors.redAccent)),
              onPressed: () { Navigator.of(context).pop(true); },
            ),
          ],
        );
      },
    );
    if (discardChanges == true) {
      setState(() {
        _isEditMode = false;
        _initializeEditableDataAndControllers(widget.food);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edição cancelada. Alterações descartadas.')));
    }
  }

  void _onCancel() {
    if (_isSaving) return;
    if (_isEditMode && _wereChangesMade()) {
      _showCancelConfirmationDialog();
    } else {
      setState(() {
        _isEditMode = false;
        _initializeEditableDataAndControllers(widget.food);
      });
    }
  }

  // Função auxiliar para validação de campos numéricos (pode ser expandida)
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

  Widget _buildDetailRow(String label, String? displayValue, {TextEditingController? controller, bool isSubItem = false, bool isNumeric = false, bool isLastField = false, bool isReadOnlyInEditMode = false, String? Function(String?)? customValidator}) {
    bool isCurrentlyEditable = _isEditMode && controller != null && !_isSaving && !isReadOnlyInEditMode;
    if (!_isEditMode || controller == null || (isReadOnlyInEditMode && _isEditMode)) {
      return Padding(
        padding: EdgeInsets.only(left: isSubItem ? 16.0 : 0, top: 8.0, bottom: 8.0, right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: isSubItem ? Colors.white60 : Colors.white70, fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayValue ?? 'N/A',
                textAlign: TextAlign.end,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: isSubItem ? FontWeight.normal : FontWeight.w500)
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: isSubItem ? 16.0 : 0, top: 2.0, bottom: 2.0, right: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: isSubItem ? 3 : 2,
            child: Text(label, style: TextStyle(color: isSubItem ? Colors.white70 : Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: isSubItem ? 2 : 3,
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
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _isSaving ? Colors.grey[700]! : Colors.greenAccent)),
                errorStyle: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w500),
                errorMaxLines: 2,
              ),
              textAlign: TextAlign.end,
              textInputAction: isLastField ? TextInputAction.done : TextInputAction.next,
              validator: customValidator ?? (value) {
                if (label == "Nome" && (value == null || value.isEmpty)) {
                  return 'Nome é obrigatório';
                }
                // Validações numéricas básicas são tratadas por _validateNumericField se customValidator não for fornecido para eles.
                // Se isNumeric for true mas customValidator não estiver definido, você pode querer chamar _validateNumericField aqui
                // como um fallback, ou garantir que customValidator seja sempre passado para campos numéricos.
                return null;
              },
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
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: _isSaving ? Colors.grey[700]! : Colors.greenAccent)),
                              errorStyle: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w500),
                            ),
                            validator: (value) {
                              if (fieldSet.quantityController.text.isNotEmpty || fieldSet.unitController.text.isNotEmpty) {
                                if (value == null || value.isEmpty) {
                                  return 'Nome obrigatório se Qtd/Unidade preenchidos';
                                }
                              }
                              // TODO: Adicionar validação de nome de micronutriente duplicado (idealmente no _onSave ou validador de formulário global)
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
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: _isSaving ? Colors.grey[700]! : Colors.greenAccent)),
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
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: _isSaving ? Colors.grey[700]! : Colors.greenAccent))
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
              icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
              label: const Text('Adicionar Micronutriente', style: TextStyle(color: Colors.greenAccent)),
              onPressed: _addMicronutrientField,
            ),
          ),
      ],
    );
  }

  Widget _buildNutrientCard(String title, List<Widget> details, {Widget? editSection}) {
    return Card(
      color: const Color(0xFF2A2A3D),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_isEditMode && editSection != null) 
              editSection 
            else 
              ...details,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayFood = _isEditMode && !_isSaving ? _editableFoodData : widget.food;
    final nutritionalInfoDisplay = displayFood.nutritionalInfo;
    final macronutrientsDisplay = nutritionalInfoDisplay.macronutrients;
    final carbsDisplay = macronutrientsDisplay?.carbohydrates;
    final fatsDisplay = macronutrientsDisplay?.fats;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? "Editar Comida" : displayFood.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF101827),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _isSaving ? Colors.grey : Colors.white),
          onPressed: () {
            if (_isSaving) return;
            if (_isEditMode && _wereChangesMade()) {
              _showCancelConfirmationDialog();
            } else if (_isEditMode) {
              _onCancel(); 
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        iconTheme: IconThemeData(color: _isSaving ? Colors.grey : Colors.white),
        actions: [
          if (_isEditMode)
            _isSaving 
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                )
              : IconButton(
                  icon: const Icon(Icons.done, color: Colors.white),
                  onPressed: _isSaving ? null : _onSave, 
                )
          else
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _isSaving ? null : _toggleEditMode,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildNutrientCard('Informações Gerais', [
                _buildDetailRow('Nome', displayFood.name, controller: _nameController, customValidator: (value) {
                  if (value == null || value.isEmpty) return 'Nome é obrigatório';
                  return null;
                }),
                _buildDetailRow('Marca', displayFood.brand, controller: _brandController),
                _buildDetailRow('Cód. Barras', displayFood.barCode, controller: _barCodeController),
                _buildDetailRow('Revisado', displayFood.isRevised ? 'Sim' : 'Não', isReadOnlyInEditMode: true),
                _buildDetailRow('Porção (g)', nutritionalInfoDisplay.servingSize.toStringAsFixed(1), controller: _servingSizeController, isNumeric: true, customValidator: (value) => _validateNumericField(value, fieldName: 'Porção', isRequired: true, allowZero: false, allowNegative: false)),
                _buildDetailRow('Calorias (kcal)', nutritionalInfoDisplay.calories?.toStringAsFixed(1), controller: _caloriesController, isNumeric: true, customValidator: (value) => _validateNumericField(value, fieldName: 'Calorias', allowNegative: false)),
              ]),
              
              _buildNutrientCard('Macronutrientes (por porção)', 
                macronutrientsDisplay == null && !_isEditMode ? 
                  [_buildDetailRow('Dados Indisponíveis', null)] :
                [
                  _buildDetailRow('Proteínas (g)', macronutrientsDisplay?.proteins?.toStringAsFixed(1), controller: _proteinsController, isNumeric: true, customValidator: (value) => _validateNumericField(value, fieldName: 'Proteínas', allowNegative: false)),
                  
                  // Carboidratos
                  _buildDetailRow('Carb. Totais (g)', carbsDisplay?.total.toStringAsFixed(1), controller: _carbsTotalController, isNumeric: true, customValidator: (value) {
                    final validation = _validateNumericField(value, fieldName: 'Carb. Totais', allowNegative: false, 
                                      isRequired: _carbsDietaryFiberController.text.isNotEmpty || _carbsSugarTotalController.text.isNotEmpty);
                    if (validation != null) return validation;
                    return null;
                  }),
                  _buildDetailRow('  Fibra (g)', carbsDisplay?.dietaryFiber?.toStringAsFixed(1), controller: _carbsDietaryFiberController, isSubItem: true, isNumeric: true, customValidator: (value) {
                    final validation = _validateNumericField(value, fieldName: 'Fibra', allowNegative: false);
                    if (validation != null) return validation;
                    final totalCarbs = double.tryParse(_carbsTotalController.text);
                    final fiber = double.tryParse(value!);
                    if (totalCarbs != null && fiber != null && fiber > totalCarbs) {
                      return 'Fibra > Carb. Totais';
                    }
                    return null;
                  }),
                  _buildDetailRow('  Açúc. Totais (g)', carbsDisplay?.sugar?.total.toStringAsFixed(1), controller: _carbsSugarTotalController, isSubItem: true, isNumeric: true, customValidator: (value) {
                    final validation = _validateNumericField(value, fieldName: 'Açúc. Totais', allowNegative: false,
                                      isRequired: _carbsSugarAddedController.text.isNotEmpty || _carbsSugarAlcoholsController.text.isNotEmpty);
                    if (validation != null) return validation;
                    final totalCarbs = double.tryParse(_carbsTotalController.text);
                    final sugarTotal = double.tryParse(value!);
                    if (totalCarbs != null && sugarTotal != null && sugarTotal > totalCarbs) {
                      return 'Açúc. Totais > Carb. Totais';
                    }
                    return null;
                  }),
                  _buildDetailRow('    Adicion. (g)', carbsDisplay?.sugar?.addedSugar?.toStringAsFixed(1), controller: _carbsSugarAddedController, isSubItem: true, isNumeric: true, customValidator: (value) {
                    final validation = _validateNumericField(value, fieldName: 'Açúc. Adic.', allowNegative: false);
                    if (validation != null) return validation;
                    final totalSugar = double.tryParse(_carbsSugarTotalController.text);
                    final addedSugar = double.tryParse(value!);
                    if (totalSugar != null && addedSugar != null && addedSugar > totalSugar) {
                      return 'Adicion. > Açúc. Totais';
                    }
                    return null;
                  }),
                  _buildDetailRow('    Polióis (g)', carbsDisplay?.sugar?.sugarAlcohols?.toStringAsFixed(1), controller: _carbsSugarAlcoholsController, isSubItem: true, isNumeric: true, customValidator: (value) => _validateNumericField(value, fieldName: 'Polióis', allowNegative: false)),
                  
                  // Gorduras
                  _buildDetailRow('Gord. Totais (g)', fatsDisplay?.total.toStringAsFixed(1), controller: _fatsTotalController, isNumeric: true, customValidator: (value) {
                    return _validateNumericField(value, fieldName: 'Gord. Totais', allowNegative: false,
                                     isRequired: _fatsSaturatedController.text.isNotEmpty || _fatsTransController.text.isNotEmpty || _fatsPolyunsaturatedController.text.isNotEmpty || _fatsMonounsaturatedController.text.isNotEmpty);
                  }),
                  _buildDetailRow('  Saturadas (g)', fatsDisplay?.saturatedFat?.toStringAsFixed(1), controller: _fatsSaturatedController, isSubItem: true, isNumeric: true, customValidator: (value) {
                    final validation = _validateNumericField(value, fieldName: 'Saturadas', allowNegative: false);
                    if (validation != null) return validation;
                    final totalFats = double.tryParse(_fatsTotalController.text);
                    final saturated = double.tryParse(value!);
                    if (totalFats != null && saturated != null && saturated > totalFats) {
                      return 'Saturadas > Gord. Totais';
                    }
                    return null;
                  }),
                  _buildDetailRow('  Trans (g)', fatsDisplay?.transFat?.toStringAsFixed(1), controller: _fatsTransController, isSubItem: true, isNumeric: true, customValidator: (value) {
                     final validation = _validateNumericField(value, fieldName: 'Trans', allowNegative: false);
                    if (validation != null) return validation;
                    final totalFats = double.tryParse(_fatsTotalController.text);
                    final trans = double.tryParse(value!);
                    if (totalFats != null && trans != null && trans > totalFats) {
                      return 'Trans > Gord. Totais';
                    }
                    return null;
                  }),
                  _buildDetailRow('  Poli-insat. (g)', fatsDisplay?.polyunsaturatedFat?.toStringAsFixed(1), controller: _fatsPolyunsaturatedController, isSubItem: true, isNumeric: true, customValidator: (value) {
                    final validation = _validateNumericField(value, fieldName: 'Poli-insat.', allowNegative: false);
                    if (validation != null) return validation;
                    final totalFats = double.tryParse(_fatsTotalController.text);
                    final poly = double.tryParse(value!);
                    if (totalFats != null && poly != null && poly > totalFats) {
                      return 'Poli-insat. > Gord. Totais';
                    }
                    return null;
                  }),
                  _buildDetailRow('  Monoinsat. (g)', fatsDisplay?.monounsaturatedFat?.toStringAsFixed(1), controller: _fatsMonounsaturatedController, isSubItem: true, isNumeric: true, customValidator: (value) {
                    final validation = _validateNumericField(value, fieldName: 'Monoinsat.', allowNegative: false);
                    if (validation != null) return validation;
                    final totalFats = double.tryParse(_fatsTotalController.text);
                    final mono = double.tryParse(value!);
                    if (totalFats != null && mono != null && mono > totalFats) {
                      return 'Monoinsat. > Gord. Totais';
                    }
                    return null;
                  }),
                  _buildDetailRow('  Colesterol (mg)', fatsDisplay?.cholesterol?.toStringAsFixed(1), controller: _fatsCholesterolController, isSubItem: true, isNumeric: true, isLastField: true, customValidator: (value) => _validateNumericField(value, fieldName: 'Colesterol', allowNegative: false)),
                ]
              ),

              _buildNutrientCard('Micronutrientes (por porção)', 
                nutritionalInfoDisplay.micronutrients == null || nutritionalInfoDisplay.micronutrients!.isEmpty 
                  ? [_buildDetailRow('Nenhum micronutriente informado', null)] 
                  : nutritionalInfoDisplay.micronutrients!.entries.map((entry) {
                      return _buildDetailRow('${entry.key}', '${entry.value.quantity.toStringAsFixed(2)} ${entry.value.unit}');
                    }).toList(),
                editSection: _buildMicronutrientsEditSection(),
              ),

              if (_isEditMode)
                Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        icon: const Icon(Icons.cancel_outlined, color: Colors.white70),
                        label: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                        onPressed: _isSaving ? null : _onCancel,
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: _isSaving 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.save_alt_outlined),
                        label: Text(_isSaving ? 'Salvando...' : 'Salvar Alterações'),
                        onPressed: _isSaving ? null : _onSave, 
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSaving ? Colors.grey[600] : Colors.green, 
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
