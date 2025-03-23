import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../components/shapeUpLogo.dart';
import '../models/CarouselItem.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Colors.transparent, // Opcional: Remove a cor de fundo da AppBar
          elevation: 0, // Opcional: Remove a sombra da AppBar
        ),
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
              'Transforme sua rotina, conecte-se com sua evolução. Nutrição, treinos e amizades em um só lugar.',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(),
              child: Text(
                'E-mail',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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

            Padding(
              padding: const EdgeInsets.only(),
              child: Text(
                'Senha',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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

            SizedBox(height: 35),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF159CD5),
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
                onPressed: () {
                  print("Botão Login Continuar com e-mail");
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
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Center(
                child: TextButton(
                  onPressed: null,
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
            ),

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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: IconButton(
                    onPressed: () {
                      print("Botão do Facebook clicado");
                    },
                    icon: Icon(
                      Icons.facebook,
                      size: 30,
                      color: Color(0xFF191F2B),
                    ),
                    splashRadius: 20,
                  ),
                ),

                SizedBox(width: 20),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: IconButton(
                    onPressed: () {
                      print("Botão do Google clicado");
                    },
                    icon: Icon(
                      Icons.g_mobiledata_rounded,
                      size: 30,
                      color: Color(0xFF191F2B),
                    ),
                    splashRadius: 20,
                  ),
                ),
              ],
            ),

            SizedBox(width: 20),

            Padding(
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
            ),
          ],
        ),
      ),
    );
  }
}
