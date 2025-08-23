import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/components/bottom_nav_bar.dart';
import 'package:shape_up_app/dtos/notificationService/notification_dto.dart';
import 'package:shape_up_app/enums/notificationService/notification_topic.dart';
import 'package:shape_up_app/pages/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/notification_service.dart';

import 'firebase_options.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver = RouteObserver<PageRoute<dynamic>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initializeLocalNotifications();

  await dotenv.load();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWebSocket();
    _initializeFCM();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService.stopConnection();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeWebSocket();
    } else if (state == AppLifecycleState.paused) {
      NotificationService.stopConnection();
    }
  }

  Future<void> _initializeWebSocket() async {
    final userId = await AuthenticationService.getProfileId();
    if (userId.isNotEmpty) {
      await NotificationService.initializeConnection(userId);
    }
  }

  void _initializeFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        NotificationService.showNotification(NotificationDto(
          topic: NotificationTopic.values.firstWhere(
                  (e) => e.toString() == 'NotificationTopic.${message.data['topic']}'),
          title: message.notification!.title,
          body: message.notification!.body,
          metadata: Map<String, String>.from(message.data),
        ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      //TODO lidar com mensagem quando o app é aberto a partir de uma notificação
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      NotificationService.updateDeviceToken(newToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorObservers: [routeObserver],
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF191F2B)),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            Future.microtask(() async {
              String token = (await snapshot.data!.getIdToken())!;
              String profileId = snapshot.data!.uid;
              await AuthenticationService.saveToken(token);
              await AuthenticationService.saveProfileId(profileId);

              String? deviceToken = await FirebaseMessaging.instance.getToken();
              if (deviceToken != null) {
                await NotificationService.saveDeviceToken(deviceToken);
                await NotificationService.logIn(deviceToken);
              }
            });

            return BottomNavBar();
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Main();
        },
      ),
    );
  }
}