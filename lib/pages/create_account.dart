import 'dart:async';

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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  String? _selectedCountry;
  DateTime? _selectedBirthDate;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isEmailAvailable = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _debounceTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1, milliseconds: 500), () async {
      if (_emailController.text.isNotEmpty) {
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text,
            password: 'dummyPassword',
          );
        } on FirebaseAuthException catch (e) {
          if(e.code == 'invalid-credential') {
            _isEmailAvailable = false;
          }
          else{
            _isEmailAvailable = true;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: backButton(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: screenHeight * 0.009),
                    Center(child: shapeUpLogo(screenWidth * 0.45)),
                    SizedBox(height: screenHeight * 0.03),
                    Center(
                      child: Text(
                        'ShapeUp',
                        style: TextStyle(
                          fontSize: screenHeight * 0.035,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Center(
                      child: Text(
                        'Transforme sua rotina, conecte-se com sua evolução. '
                            'Nutrição, treinos e amizades em um só lugar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenHeight * 0.016,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildTextField(
                      'E-mail',
                      _emailController,
                      TextInputType.emailAddress,
                    ),
                    if (!_isEmailAvailable)
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.005),
                        child: const Text(
                          'E-mail não está disponível.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildTextField(
                      'Primeiro Nome',
                      _firstNameController,
                      TextInputType.text,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildTextField(
                      'Sobrenome',
                      _lastNameController,
                      TextInputType.text,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildDatePicker('Selecione sua Data de Nascimento'),
                    SizedBox(height: screenHeight * 0.02),
                    _buildPasswordField(
                      'Senha',
                      _passwordController,
                      _isPasswordVisible,
                          () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildPasswordField(
                      'Confirmar Senha',
                      _confirmPasswordController,
                      _isConfirmPasswordVisible,
                          () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _buildDropdown('País', ['Brasil'], (value) {
                      setState(() {
                        _selectedCountry = value;
                      });
                    }),
                    SizedBox(height: screenHeight * 0.02),
                    _buildTextField(
                      'Código postal',
                      _postalCodeController,
                      TextInputType.number,
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    _buildButton('Criar conta', () async {
                      if(_emailController.text.isEmpty){
                        _showValidationErrorAlertDialog('Por favor, insira um e-mail.');
                        return;
                      }

                      if(_firstNameController.text.isEmpty){
                        _showValidationErrorAlertDialog('Por favor, insira seu primeiro nome.');
                        return;
                      }

                      if(_lastNameController.text.isEmpty){
                        _showValidationErrorAlertDialog('Por favor, insira seu sobrenome.');
                        return;
                      }

                      if(_selectedBirthDate == null){
                        _showValidationErrorAlertDialog('Por favor, selecione sua data de nascimento.');
                        return;
                      }

                      if(_passwordController.text.isEmpty){
                        _showValidationErrorAlertDialog('Por favor, insira uma senha.');
                        return;
                      }

                      if(_confirmPasswordController.text.isEmpty){
                        _showValidationErrorAlertDialog('Por favor, confirme sua senha.');
                        return;
                      }

                      if(_passwordController.text != _confirmPasswordController.text){
                        _showValidationErrorAlertDialog('As senhas não coincidem.');
                        return;
                      }

                      if(_selectedCountry == null){
                        _showValidationErrorAlertDialog('Por favor, selecione seu país.');
                        return;
                      }

                      if(_postalCodeController.text.isEmpty){
                        _showValidationErrorAlertDialog('Por favor, insira seu código postal.');
                        return;
                      }

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
                    SizedBox(height: screenHeight * 0.10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showValidationErrorAlertDialog(String message){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101827), // Cor de fundo consistente
          title: const Text(
            'Erro',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70, // Cor do texto ajustada
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Color(0xFF159CD5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF159CD5),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDatePicker(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), // Consistent spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        surface: Color(0xFF1F2937),
                        onSurface: Colors.white,
                      ),
                      dialogBackgroundColor: const Color(0xFF101827),
                    ),
                    child: child!,
                  );
                },
              );

              if (selectedDate != null) {
                _selectedBirthDate = selectedDate;
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white70),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedBirthDate != null ? '${_selectedBirthDate!.day.toString().padLeft(2, '0')}/${_selectedBirthDate!.month.toString().padLeft(2, '0')}/${_selectedBirthDate!.year}': 'Selecione uma data', // Placeholder text
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType keyboardType, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Digite seu $label',
            hintStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF1F2937),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white70),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(
      String label,
      TextEditingController controller,
      bool isVisible,
      VoidCallback toggleVisibility,
      ) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Center(
      child: ElevatedButton(
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
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      dropdownColor: const Color(0xFF1F2937),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(color: Colors.white, backgroundColor: const Color(0xFF1F2937)),));
      }).toList(),
      onChanged: onChanged,
    );
  }
}