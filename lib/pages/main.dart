import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shape_up_app/functions/change_page.dart';
import 'package:shape_up_app/pages/create_account.dart';
import 'package:shape_up_app/pages/login.dart';

import '../components/shape_up_logo.dart';
import '../models/carousel_item.dart';

class Main extends StatelessWidget {
  Main({super.key});

  final List<CarouselItem> carouselItems = [
    CarouselItem(
        title: "ShapeUp",
        description:
        "Uma rede social inovadora que conecta profissionais de nutrição e educação física a clientes. Com ferramentas para prescrição de treinos e dietas, além de um ambiente interativo, o ShapeUp torna o acompanhamento acessível, eficiente e motivador."),
    CarouselItem(
        title: "Nutrição",
        description:
        "A alimentação é essencial para a saúde e o desempenho. No ShapeUp, nutricionistas criam planos personalizados, acompanham a evolução dos clientes e oferecem suporte contínuo para uma vida mais equilibrada."),
    CarouselItem(
        title: "Treino",
        description:
        "Cada pessoa tem um objetivo único, e o ShapeUp ajuda a alcançá-lo. Personal trainers montam treinos sob medida, acompanham o progresso e ajustam planos conforme a necessidade, garantindo eficiência e resultados."),
    CarouselItem(
        title: "Conexão",
        description:
        "A motivação cresce com o apoio certo. No ShapeUp, usuários compartilham conquistas, trocam experiências e se conectam com profissionais, transformando desafios em hábitos saudáveis e duradouros.")
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: screenHeight * 0.1),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                shapeUpLogo(screenWidth * 0.6),
                SizedBox(height: screenHeight * 0.03), // Reduced spacing
                _Carousel(carouselItems: carouselItems),
              ],
            ),
            SizedBox(height: screenHeight * 0.10), // Reduced spacing
            _loginButton(context),
            SizedBox(height: screenHeight * 0.02), // Reduced spacing
            TextButton(
              onPressed: () {
                changePageStateful(context, CreateAccount());
              },
              child: Text(
                'Criar conta',
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
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

  ElevatedButton _loginButton(BuildContext context) {
    return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF159CD5),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                fixedSize: const Size(260, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

              ),
              onPressed: () {
                print("Botão Login clicado");
                changePageStateful(context, Login());
              },
              child: const Text('Login'),
            );
  }
}

class _Carousel extends StatefulWidget {
  final List<CarouselItem> carouselItems;
  const _Carousel({required this.carouselItems});

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (_currentPage < widget.carouselItems.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.2, // Altura proporcional
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.carouselItems.length,
            itemBuilder: (context, index) {
              return _buildCarouselItem(widget.carouselItems[index], screenWidth);
            },
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildCarouselItem(CarouselItem item, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            item.title,
            style: TextStyle(
              fontSize: screenWidth * 0.06, // Tamanho proporcional
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
        Text(
          item.description,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.carouselItems.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Color(0xFF169CD6) : Colors.white,
          ),
        );
      }),
    );
  }
}