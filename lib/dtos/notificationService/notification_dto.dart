import 'dart:convert';
import 'package:shape_up_app/enums/notificationService/notification_topic.dart';

class NotificationDto{
  String recipientId;
  NotificationTopic topic;
  String? title;
  String? body;
  Map<String, String> metadata;

  NotificationDto({
    required this.recipientId,
    required this.topic,
    required this.title,
    required this.body,
    required this.metadata,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      recipientId: json['recipientId'],
      topic: NotificationTopic.values.firstWhere((e) => e.toString() == 'NotificationTopic.${json['topic']}'),
      title: json['title'],
      body: json['body'],
      metadata: Map<String, String>.from(jsonDecode(json['metadata']))
    );
  }
}