import 'package:shape_up_app/utils/message_decryptor.dart';

class MessageDto {
  String? id;
  String? senderId;
  String? receiverId;
  String? content;
  DateTime? timestamp;

  MessageDto({
    this.id,
    this.senderId,
    this.receiverId,
    this.content,
    this.timestamp,
  });

  MessageDto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    content = MessageDecryptor.decryptMessage(json['encryptedMessage']);
    timestamp = DateTime.parse(json['timestamp']);
  }

  static List<MessageDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => MessageDto.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {'senderId': senderId, 'receiverId': receiverId, 'message': content};
  }
}
