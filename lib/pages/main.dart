import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child:  Center(

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              _shapeUpLogo(),

              SizedBox(height: 45),

              Text(
                "ShapeUp",
                style: const TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),

              SizedBox(height: 15),

              Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                style: const TextStyle(
                    fontSize: 13,
                  color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),

              SizedBox(height: 130),

              _loginButton(),

              SizedBox(height: 30),

              const Padding(
                padding: EdgeInsets.only(top: 10), // Espaçamento acima do TextButton
                child: TextButton(
                  onPressed: null,
                  child: Text('Criar conta',
                  style: const TextStyle(
                      fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),),
                ),
              ),

            ],
          ),
        ),
      )
    );
  }

  SvgPicture _shapeUpLogo() {
    return SvgPicture.asset(
              'assets/icons/shape_up.svg',
              height: 270,
              fit: BoxFit.contain,
            );
  }

  ElevatedButton _loginButton() {
    return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF159CD5), // Cor de fundo vermelha
                foregroundColor: Colors.white, // Cor do texto branca
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                fixedSize: const Size(260, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

              ),
              onPressed: () {
                print("Botão Login clicado");
              },
              child: const Text('Login'),
            );
  }
}