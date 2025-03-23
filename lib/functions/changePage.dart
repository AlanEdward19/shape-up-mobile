import 'package:flutter/material.dart';

void changePageStateless(BuildContext context, StatelessWidget newPage) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => newPage),
  );
}

void changePageStateful(BuildContext context, StatefulWidget newPage) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => newPage),
  );
}