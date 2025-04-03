import 'package:flutter/material.dart';

class ImageCarouselWithIndicator extends StatefulWidget {
  final List<String> imageUrls;

  const ImageCarouselWithIndicator({super.key, required this.imageUrls});

  @override
  State<ImageCarouselWithIndicator> createState() => _ImageCarouselWithIndicatorState();
}

class _ImageCarouselWithIndicatorState extends State<ImageCarouselWithIndicator> {
  int _currentPage = 0;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                widget.imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.imageUrls.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 16 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
