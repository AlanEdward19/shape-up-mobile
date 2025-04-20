import 'dart:convert';
import 'package:shape_up_app/enums/notificationService/notification_topic.dart';

class NotificationDto{
  NotificationTopic topic;
  String? title;
  String? body;
  Map<String, String> metadata;

  NotificationDto({
    required this.topic,
    required this.title,
    required this.body,
    required this.metadata,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      topic: notificationTopicMap[json['topic']]!,
      title: json['title'],
      body: json['body'],
      metadata: Map<String, String>.from(json['metadata'])
    );
  }
}