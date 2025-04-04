import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/components/bottomNavBar.dart';
import 'package:shape_up_app/pages/feed.dart';
import 'package:shape_up_app/pages/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shape_up_app/services/AuthenticationService.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await dotenv.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: Color(0xFF191F2B)),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            Future.microtask(() async {
              String token = (await snapshot.data!.getIdToken())!;
              AuthenticationService.saveToken(token);
            });

            return BottomNavBar();
          }
          else if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }

          return Main();
        },
      ),
    );
  }
}
