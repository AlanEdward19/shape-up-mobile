
import 'package:flutter/material.dart';
import 'package:shape_up_app/enums/nutritionService/DayOfWeek.dart';
import 'package:shape_up_app/services/daily_menu_service.dart';

class CreateDailyMenuPage extends StatefulWidget {
  const CreateDailyMenuPage({super.key});

  @override
  State<CreateDailyMenuPage> createState() => _CreateDailyMenuPageState();
}

class _CreateDailyMenuPageState extends State<CreateDailyMenuPage> {
  final _formKey = GlobalKey<FormState>();
  DayOfWeek? _selectedDayOfWeek;
  String _mealIdsInput = ''; // Temporário para input de mealIds

  bool _isLoading = false;

  // TODO: Carregar a lista real de dias da semana do enum
  final List<DayOfWeek> _daysOfWeek = DayOfWeek.values;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        // Processar _mealIdsInput para List<String>
        // Por enquanto, vamos assumir que são IDs separados por vírgula
        final mealIds = _mealIdsInput.split(',').map((id) => id.trim()).where((id) => id.isNotEmpty).toList();

        if (_selectedDayOfWeek == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecione um dia da semana.'), backgroundColor: Colors.red),
          );
          setState(() { _isLoading = false; });
          return;
        }

        if (mealIds.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, adicione IDs de refeições.'), backgroundColor: Colors.red),
          );
          setState(() { _isLoading = false; });
          return;
        }

        // TODO: Substituir pela chamada real ao serviço quando a UI de seleção de refeições estiver melhor
        // Por enquanto, esta chamada pode falhar se mealIds não forem válidos no backend
        await DailyMenuService.createDailyMenuForOwnUser(
          dayOfWeek: _selectedDayOfWeek,
          mealIds: mealIds,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cardápio criado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Retorna true para indicar sucesso
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao criar cardápio: \$e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Novo Cardápio', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF101827),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<DayOfWeek>(
                value: _selectedDayOfWeek,
                hint: const Text('Selecione o dia da semana', style: TextStyle(color: Colors.white70)),
                dropdownColor: const Color(0xFF2A2A3D),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2A2A3D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                ),
                items: _daysOfWeek.map((DayOfWeek day) {
                  return DropdownMenuItem<DayOfWeek>(
                    value: day,
                    child: Text(day.toString().split('.').last, style: const TextStyle(color: Colors.white)), // Melhora a exibição do enum
                  );
                }).toList(),
                onChanged: (DayOfWeek? newValue) {
                  setState(() {
                    _selectedDayOfWeek = newValue;
                  });
                },
                validator: (value) => value == null ? 'Por favor, selecione um dia' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'IDs das Refeições (separados por vírgula)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF2A2A3D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                   enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                ),
                onSaved: (value) => _mealIdsInput = value ?? '',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira os IDs das refeições';
                  }
                  // Validação simples de formato (apenas para exemplo)
                  final ids = value.split(',').map((id) => id.trim()).toList();
                  if (ids.any((id) => id.isEmpty && ids.length > 1)) {
                    return 'Formato de ID inválido.';
                  }
                  return null;
                },
              ),
              // TODO: Adicionar uma UI melhor para selecionar refeições (mealIds)
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.green))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 16, color: Color(0xFF101827)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: _submitForm,
                      child: const Text('Salvar Cardápio', style: TextStyle(color: Color(0xFF101827), fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
