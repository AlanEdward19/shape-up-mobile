import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shape_up_app/components/post_card.dart';
import 'package:shape_up_app/dtos/notificationService/notification_dto.dart';
import 'package:shape_up_app/dtos/socialService/post_reaction_dto.dart';
import 'package:shape_up_app/enums/notificationService/notification_topic.dart';
import 'package:shape_up_app/enums/socialService/reaction_type.dart';
import 'package:shape_up_app/pages/profile.dart';
import 'package:shape_up_app/pages/profile_post.dart';
import 'package:shape_up_app/services/notification_service.dart';
import 'package:shape_up_app/services/social_service.dart';

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
        _notifications = List.from(_notifications)..insert(0, notification);
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
        itemBuilder: (itemContext, index) {
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
              _markAsRead(notification);
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
              onTap: () async {
                _markAsRead(notification);

                if (notification.topic == NotificationTopic.FriendRequest ||
                    notification.topic == NotificationTopic.NewFollower) {
                  final senderId = notification.metadata['userId'];
                  if (senderId != null) {
                    Navigator.push(
                      itemContext,
                      MaterialPageRoute(
                        builder: (itemContext) => Profile(profileId: senderId),
                      ),
                    );
                  }
                } else if (notification.topic == NotificationTopic.Reaction ||
                    notification.topic == NotificationTopic.Comment) {
                  final postId = notification.metadata['postId'];
                  if (postId != null) {
                    final post = await SocialService.getPostAsync(postId);
                    if (post != null) {
                      final profilePosts = await SocialService.getPostsByProfileIdAsync(post.publisherId);
                      final postIndex = profilePosts.indexWhere((p) => p.id == postId);
                      if(mounted) {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (itemContext) => ProfilePost(initialIndex: postIndex,posts: profilePosts),
                        ),
                      );
                      }
                    }
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}