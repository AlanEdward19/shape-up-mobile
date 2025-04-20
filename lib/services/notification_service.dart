import 'dart:async';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shape_up_app/dtos/notificationService/notification_dto.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:signalr_core/signalr_core.dart';

class NotificationService {
  static final String baseUrl = dotenv.env['NOTIFICATION_SERVICE_BASE_URL']!;
  static late HubConnection _hubConnection;

  static final StreamController<NotificationDto> _notificationStreamController = StreamController<NotificationDto>.broadcast();
  static Stream<NotificationDto> get notificationStream => _notificationStreamController.stream;

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
          final notification = NotificationDto.fromJson(arguments[0] as Map<String, dynamic>);
          _notificationStreamController.add(notification);
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

  static Future<void> stopConnection() async {
    await _hubConnection.stop();
    print('Conexão com o SignalR encerrada.');
  }
}