import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shape_up_app/dtos/notificationService/notification_dto.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:signalr_core/signalr_core.dart';

class NotificationService {
  static final storage = FlutterSecureStorage();

  static final String baseUrl = dotenv.env['NOTIFICATION_SERVICE_BASE_URL']!;

  static Map<String, String> createHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static late HubConnection _hubConnection;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static final StreamController<NotificationDto> _notificationStreamController =
  StreamController<NotificationDto>.broadcast();
  static Stream<NotificationDto> get notificationStream =>
      _notificationStreamController.stream;

  static final List<NotificationDto> _notifications = [];

  static List<NotificationDto> getNotifications() {
    return List.unmodifiable(_notifications);
  }

  static Future initializeLocalNotifications() async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iOS = DarwinInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: iOS);
    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> initializeConnection(String profileId) async {
    _hubConnection = HubConnectionBuilder()
        .withUrl(
      '$baseUrl/notifications?userId=$profileId',
      HttpConnectionOptions(
        accessTokenFactory: () async {
          return await AuthenticationService.getToken();
        },
      ),
    )
        .build();

    _hubConnection.onclose((error) {
      print('Conexão encerrada: $error');
    });

    _hubConnection.on('ReceiveNotification', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final notification = NotificationDto.fromJson(
            jsonDecode(arguments[0]),
          );
          _notifications.insert(0, notification); // Armazena a notificação
          _notificationStreamController.add(notification); // Emite no stream
          showNotification(notification);
        } catch (e) {
          print('Erro ao converter notificação: $e');
        }
      } else {
        print('Nenhuma notificação recebida.');
      }
    });

    await _hubConnection.start();
    print('Conexão com o SignalR estabelecida.');
  }

  static Future<void> showNotification(NotificationDto notification) async {
    const NotificationDetails platformDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.max,
        icon: 'logo',
        enableVibration: true,
        playSound: true,
        color: Color(0xFF159CD5),
      ),
    );

    await _notificationsPlugin.show(
      0,
      notification.title,
      notification.body,
      payload: 'asdsada',
      platformDetails,
    );
  }

  static void removeNotification(NotificationDto notification) {
    _notifications.remove(notification);
  }

  static Future<void> stopConnection() async {
    if (_hubConnection.state == HubConnectionState.connected) {
      await _hubConnection.stop();
    }
    print('Conexão com o SignalR encerrada.');
  }

  static Future<void> saveDeviceToken(String token) async {
    await storage.write(key: 'device_token', value: token);
  }

  static Future<void> updateDeviceToken(String token) async {
    String? oldToken = await storage.read(key: 'device_token');

    if (oldToken == token) return;

    if (oldToken != null) {
      await signOut(oldToken);
    }
    await saveDeviceToken(token);
    await logIn(token);
  }

  static Future<void> logIn(String deviceToken) async {
    var token = await AuthenticationService.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/v1/User/LogIn'),
      headers: createHeaders(token),
      body: jsonEncode({'deviceToken': deviceToken}),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao logar com serviço de notificações");
    }
  }

  static Future<void> signOut(String deviceToken) async {
    var token = await AuthenticationService.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/v1/User/SignOut'),
      headers: createHeaders(token),
      body: jsonEncode({'deviceToken': deviceToken}),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao deslogar com serviço de notificações");
    }
  }
}