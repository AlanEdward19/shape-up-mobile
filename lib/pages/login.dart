import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shape_up_app/components/bottom_nav_bar.dart';
import 'package:shape_up_app/dtos/authService/user_data.dart';
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
      body: Padding(
        padding: const EdgeInsets.only(left: 34, right: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: shapeUpLogo(200)),

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
              ),
            ),

            SizedBox(height: 20),

            _textFieldLabel('Senha'),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
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

            SizedBox(height: 20),

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

            SizedBox(width: 20),

            _createAccountButton(),
          ],
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
                print("Botão de criar conta clicado!");
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
        onPressed: () {
          print("Botão do Facebook clicado");
        },
        icon: Icon(Icons.facebook, size: 30, color: Color(0xFF191F2B)),
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
          final now = DateTime.now().toUtc();
          await AuthenticationService.loginWithGoogle();

          var currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            final creationTime = currentUser.metadata.creationTime;

            if (creationTime != null &&
                now.difference(creationTime).inSeconds <= 20) {

              await showDialog(
                context: context,
                barrierDismissible: false, // Impede que o popup seja fechado
                builder: (BuildContext context) {
                  final TextEditingController postalCodeController =
                  TextEditingController();
                  String? selectedCountry;

                  return AlertDialog(
                    title: Text('Complete seu cadastro'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: postalCodeController,
                          decoration: InputDecoration(
                            labelText: 'Código Postal',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'País',
                            border: OutlineInputBorder(),
                          ),
                          items: ['Brasil', 'Estados Unidos']
                              .map((country) => DropdownMenuItem(
                            value: country,
                            child: Text(country),
                          ))
                              .toList(),
                          onChanged: (value) {
                            selectedCountry = value;
                          },
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          if (postalCodeController.text.isNotEmpty &&
                              selectedCountry != null) {
                             var firstName = currentUser.displayName!.split(' ').first;
                             var lastName = currentUser.displayName!.split(' ').last;

                            UserData userData = UserData(
                              firstName: firstName,
                              lastName: lastName,
                              country: selectedCountry!,
                              city: '',
                              state: '',
                              postalCode: postalCodeController.text,
                              birthDay: '',
                            );

                            var token = await AuthenticationService.getToken();
                            await AuthenticationService.enhanceToken(
                                userData, token);

                            await AuthenticationService.getToken(refreshToken: true);

                            Navigator.of(context).pop();
                          }
                        },
                        child: Text('Confirmar'),
                      ),
                    ],
                  );
                },
              );
            }

            print("Login realizado com sucesso!");

            await SocialService.viewProfileAsync(currentUser.uid);

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BottomNavBar()),
                    (Route<dynamic> route) => false
            );
          } else {
            print("Erro ao realizar login.");
          }
        },
        icon: Icon(
          Icons.g_mobiledata_rounded,
          size: 30,
          color: Color(0xFF191F2B),
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
                  title: Text('Redefinir senha'),
                  content: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Digite seu e-mail',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (emailController.text.isNotEmpty) {
                          try {
                            await AuthenticationService.sendPasswordResetEmail(emailController.text);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('E-mail de redefinição enviado!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro ao enviar e-mail.')),
                            );
                          }
                        }
                      },
                      child: Text('Enviar'),
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
          if(_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
            await AuthenticationService.loginWithEmailAndPassword(_emailController.text, _passwordController.text);

            var currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              print("Login realizado com sucesso!");

              await SocialService.viewProfileAsync(currentUser.uid);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BottomNavBar()),
                    (Route<dynamic> route) => false
              );
            } else {
              print("Erro ao realizar login.");
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
