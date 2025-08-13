import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Color borderColor;
  final double borderWidth;

  const CircularImage({
    Key? key,
    required this.imageUrl,
    this.size = 50.0,
    this.borderColor = Colors.blue,
    this.borderWidth = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        )
            : Icon(
          Icons.image_not_supported,
          size: size,
          color: Colors.grey,
        ),
      ),
    );
  }
}