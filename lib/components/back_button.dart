import 'package:flutter/material.dart';

AppBar backButton(BuildContext context) {
  return AppBar(
    leading: IconButton(
      icon: Icon(Icons.arrow_back, color: Colors.white,),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
  );
}