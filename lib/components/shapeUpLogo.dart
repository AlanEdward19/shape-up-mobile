import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

SvgPicture shapeUpLogo(double height) {
  return SvgPicture.asset(
    'assets/icons/shape_up.svg',
    height: height,
    fit: BoxFit.contain,
  );
}