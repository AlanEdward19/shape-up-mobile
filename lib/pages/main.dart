import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../models/CarouselItem.dart';

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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 34),
        child:  Center(

          child: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              _shapeUpLogo(),

              SizedBox(height: 45),

              _Carousel(carouselItems: carouselItems),

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

class _Carousel extends StatefulWidget {
  final List<CarouselItem> carouselItems;
  const _Carousel({Key? key, required this.carouselItems}) : super(key: key);

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
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.carouselItems.length,
            itemBuilder: (context, index) {
              return _buildCarouselItem(widget.carouselItems[index]);
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildCarouselItem(CarouselItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
            child: Text(
            item.title,
            style: const TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
          ),
        )),

        const SizedBox(height: 15),

        Text(
          item.description,
          style: const TextStyle(
            fontSize: 13,
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