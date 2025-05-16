import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shape_up_app/components/back_button.dart';
import 'package:shape_up_app/dtos/authService/user_data.dart';
import 'package:shape_up_app/pages/main.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import '../components/shape_up_logo.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmationCodeController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  DateTime? _selectedBirthDate;

  bool _isCodeSent = false;
  bool _isCodeVerified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: backButton(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Center(child: shapeUpLogo(200)),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'ShapeUp',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Transforme sua rotina, conecte-se com sua evolução. '
                  'Nutrição, treinos e amizades em um só lugar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'E-mail',
                _emailController,
                TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              if (!_isCodeSent)
                _buildButton('Enviar código de confirmação', () {
                  setState(() {
                    _isCodeSent = true;
                  });
                }),
              if (_isCodeSent) ...[
                _buildTextField(
                  'Código de confirmação',
                  _confirmationCodeController,
                  TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildButton('Verificar código', () {
                  if (_confirmationCodeController.text == '123456') {
                    setState(() {
                      _isCodeVerified = true;
                    });
                  }
                }),
              ],
              if (_isCodeVerified) ...[
                _buildTextField(
                  'Primeiro Nome',
                  _firstNameController,
                  TextInputType.text,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Sobrenome',
                  _lastNameController,
                  TextInputType.text,
                ),
                const SizedBox(height: 20),
                _buildDatePicker('Selecione sua Data de Nascimento'),
                const SizedBox(height: 20),
                _buildTextField(
                  'Senha',
                  _passwordController,
                  TextInputType.visiblePassword,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  'Confirmar Senha',
                  _confirmPasswordController,
                  TextInputType.visiblePassword,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                _buildDropdown('País', ['Brasil', 'Estados Unidos'], (value) {
                  setState(() {
                    _selectedCountry = value;
                  });
                }),
                const SizedBox(height: 20),
                _buildDropdown('Estado', ['São Paulo', 'Rio de Janeiro'], (
                  value,
                ) {
                  setState(() {
                    _selectedState = value;
                  });
                }),
                const SizedBox(height: 20),
                _buildDropdown('Cidade', ['São Paulo', 'Rio de Janeiro'], (
                  value,
                ) {
                  setState(() {
                    _selectedCity = value;
                  });
                }),
                const SizedBox(height: 20),
                _buildTextField(
                  'Código postal',
                  _postalCodeController,
                  TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildButton('Criar conta', () async {
                  if (_emailController.text.isNotEmpty &&
                      _passwordController.text.isNotEmpty) {
                    var token =
                        await AuthenticationService.createAccountWithEmailAndPassword(
                          _emailController.text,
                          _passwordController.text,
                        );

                    if (token.isNotEmpty) {
                      UserData userData = UserData(
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        country: _selectedCountry!,
                        city: _selectedCity!,
                        state: _selectedState!,
                        postalCode: _postalCodeController.text,
                        birthDay: _selectedBirthDate!.toIso8601String(),
                      );

                      await AuthenticationService.enhanceToken(userData, token);

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Main()),
                            (Route<dynamic> route) => false,
                      );
                    }
                  }
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedBirthDate = pickedDate;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          _selectedBirthDate != null
              ? "${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}"
              : label,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType, {
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF159CD5),
              fixedSize: const Size(230, 40),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: onPressed,
            child: Text(text),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: const OutlineInputBorder(),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
    );
  }
}
