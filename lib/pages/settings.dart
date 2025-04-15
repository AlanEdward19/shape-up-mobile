import 'package:flutter/material.dart';
import 'package:shape_up_app/pages/main.dart';
import 'package:shape_up_app/services/authentication_service.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Configurações",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF191F2B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await AuthenticationService.signOut();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Main()),
                    (Route<dynamic> route) => false
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Logout", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
