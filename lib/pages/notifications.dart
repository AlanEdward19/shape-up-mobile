import 'package:flutter/material.dart';
import 'package:shape_up_app/dtos/notificationService/notification_dto.dart';
import 'package:shape_up_app/services/notification_service.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationState();
}

class _NotificationState extends State<Notifications> {
  List<NotificationDto> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _listenToNotificationStream();
  }

  void _loadNotifications() {
    setState(() {
      _notifications = NotificationService.getNotifications();
    });
  }

  void _listenToNotificationStream() {
    NotificationService.notificationStream.listen((notification) {
      setState(() {
        _notifications.insert(0, notification);
      });
    });
  }

  void _markAsRead(NotificationDto notification) {
    NotificationService.removeNotification(notification);
    setState(() {
      _notifications = NotificationService.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações', style: TextStyle(color: Colors.white),),
          backgroundColor: const Color(0xE60F1623),
          iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: _notifications.isEmpty
          ? const Center(
        child: Text(
          'Nenhuma notificação disponível',
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];

          return Dismissible(
            key: Key(notification.metadata['id'] ?? index.toString()),
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Icon(Icons.mark_email_read, color: Colors.white),
            ),
            onDismissed: (direction) {
              final removedNotification = _notifications[index];

              if (direction == DismissDirection.startToEnd) {
                _markAsRead(removedNotification);
              }
            },
            child: ListTile(
              title: Text(
                notification.title ?? 'Sem título',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
              subtitle: Text(notification.body ?? '',
                style: TextStyle(
                  color: Colors.grey
                ),
              ),
              onTap: () {
                _markAsRead(notification);
                // Substitua pelo redirecionamento para outra página
                print('Abrindo notificação: ${notification.metadata}');
              },
            ),
          );
        },
      ),
    );
  }
}