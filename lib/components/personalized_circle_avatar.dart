
import 'package:flutter/material.dart';

Widget personalizedCircleAvatar(String imageUrl, String profileName, double radius) {
  String firstName = '';
  String lastName = '';

  if (profileName.isNotEmpty) {
    List<String> nameParts = profileName.split(' ');
    firstName = nameParts[0];
    lastName = nameParts.length > 1 ? nameParts[1] : '';
  }
  else {
    firstName = 'User';
    lastName = 'Name';
  }

  return CircleAvatar(
    radius: radius,
    backgroundImage: NetworkImage(imageUrl),
    child: imageUrl.isEmpty
        ? Text(
            '${firstName[0]}${lastName[0]}',
            style: TextStyle(fontSize: radius - 4, color: Colors.white),
          )
        : null,
  );
}