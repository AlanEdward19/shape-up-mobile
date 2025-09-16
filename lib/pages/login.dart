import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shape_up_app/components/bottom_nav_bar.dart';
import 'package:shape_up_app/dtos/authService/user_data.dart';
import 'package:shape_up_app/functions/change_page.dart';
import 'package:shape_up_app/pages/create_account.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/social_service.dart';

import '../components/back_button.dart';
import '../components/shape_up_logo.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: backButton(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.009),
                      Center(child: shapeUpLogo(MediaQuery.of(context).size.height * 0.22)),
                      SizedBox(height: 30),
                      Text(
                        'ShapeUp',
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Transforme sua rotina, conecte-se com sua evolução. '
                            'Nutrição, treinos e amizades em um só lugar.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      _textFieldLabel('E-mail'),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Digite seu e-mail',
                          border: UnderlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _textFieldLabel('Senha'),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          hintText: 'Digite sua senha',
                          border: UnderlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            checkColor: Colors.white,
                            activeColor: Color(0xFF159CD5),
                            value: _rememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                            shape: CircleBorder(),
                          ),
                          Text(
                            'Lembrar-me',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _loginButton(),
                      _forgotPasswordButton(),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFF6D717A))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Ou entre com',
                              style: TextStyle(color: Color(0xFF6D717A)),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFF6D717A))),
                        ],
                      ),
                      SizedBox(height: 20),
                      _loginWithSsoButton(),
                      SizedBox(height: 20),
                      _createAccountButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding _textFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Row _loginWithSsoButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _loginWithFacebookButton(),
        SizedBox(width: 20),
        _loginWithGoogleButton(),
      ],
    );
  }

  Padding _createAccountButton() {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Não possui uma conta?',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6D717A),
                fontWeight: FontWeight.normal,
              ),
            ),
            TextButton(
              onPressed: () {
                changePageStateful(context, CreateAccount());
              },
              child: Text(
                'Crie uma aqui!',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _loginWithFacebookButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: IconButton(
        onPressed: () async {
          try {
            await AuthenticationService.loginWithFacebook();
            print("Login com Facebook realizado com sucesso!");
          } catch (e) {
            print("Erro ao realizar login com Facebook: $e");
          }
        },
        icon: Icon(Icons.facebook, size: 30, color: Color(0xFF101827)),
        splashRadius: 20,
      ),
    );
  }

  Container _loginWithGoogleButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: IconButton(
        onPressed: () async {
          try {
            await AuthenticationService.loginWithGoogle();

            var currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              final creationTime = currentUser.metadata.creationTime;
              final now = DateTime.now();

              if (creationTime != null && now.difference(creationTime).inSeconds <= 30) {
                String token = (await currentUser.getIdToken())!;
                showDialog(
                  context: context,
                  barrierDismissible: false, // Impede fechar o popup
                  builder: (BuildContext context) {
                    final TextEditingController postalCodeController = TextEditingController();
                    final TextEditingController countryController = TextEditingController();

                    return AlertDialog(
                      title: Text('Complete seu cadastro'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: postalCodeController,
                            decoration: InputDecoration(labelText: 'Código postal'),
                          ),
                          TextField(
                            controller: countryController,
                            decoration: InputDecoration(labelText: 'País'),
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () async{
                            if (postalCodeController.text.isNotEmpty && countryController.text.isNotEmpty) {
                              Navigator.of(context).pop();

                              UserData userData = UserData(
                                firstName: currentUser.displayName?.split(' ').first ?? '',
                                lastName: currentUser.displayName?.split(' ').last ?? '',
                                country: countryController.text,
                                postalCode: postalCodeController.text,
                                birthDay: DateTime.now().toString(),
                              );

                              await AuthenticationService.enhanceToken(userData, token);
                            }
                          },
                          child: Text('Salvar'),
                        ),
                      ],
                    );
                  },
                );
              }

              await SocialService.viewProfileAsync(currentUser.uid);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BottomNavBar()),
                    (Route<dynamic> route) => false,
              );
            }
          } catch (e) {
            print("Erro ao realizar login com Google: $e");
          }
        },
        icon: Icon(
          Icons.g_mobiledata_rounded,
          size: 30,
          color: Color(0xFF101827),
        ),
        splashRadius: 20,
      ),
    );
  }

  Padding _forgotPasswordButton() {
    return Padding(
      padding: EdgeInsets.only(top: 5),
      child: Center(
        child: TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                final TextEditingController emailController = TextEditingController();

                return AlertDialog(
                  backgroundColor: const Color(0xFF101827), // Cor de fundo consistente
                  title: Text(
                    'Redefinir senha',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white), // Cor do texto
                    decoration: InputDecoration(
                      labelText: 'Digite seu e-mail',
                      labelStyle: const TextStyle(color: Colors.white70), // Cor do rótulo
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      filled: true,
                      fillColor: const Color(0xFF1F2937), // Fundo do campo de texto
                    ),
                    keyboardType: TextInputType.emailAddress,
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
                      onPressed: () async {
                        if (emailController.text.isNotEmpty) {
                          try {
                            await AuthenticationService.sendPasswordResetEmail(emailController.text);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('E-mail de redefinição enviado!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Erro ao enviar e-mail.')),
                            );
                          }
                        }
                      },
                      child: const Text('Enviar'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(
            'Esqueceu sua senha?',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF159CD5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Center _loginButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF159CD5),
          fixedSize: const Size(230, 40),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () async {
          if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
            try {
              await AuthenticationService.loginWithEmailAndPassword(
                _emailController.text,
                _passwordController.text,
              );

              var currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                print("Login realizado com sucesso!");
                await SocialService.viewProfileAsync(currentUser.uid);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => BottomNavBar()),
                      (Route<dynamic> route) => false,
                );
              } else {
                print("Erro ao realizar login.");
              }
            } catch (e) {
              print("Erro ao realizar login: $e");
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.email, size: 30),
            SizedBox(width: 5),
            const Text('Continuar com e-mail'),
          ],
        ),
      ),
    );
  }
}