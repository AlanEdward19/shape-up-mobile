import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shape_up_app/dtos/chatService/message_dto.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  static final String baseUrl = dotenv.env['CHAT_SERVICE_BASE_URL']!;
  static late HubConnection _hubConnection;

  static Map<String, String> createHeaders(String token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    return headers;
  }

  static final StreamController<MessageDto> _messageStreamController = StreamController<MessageDto>.broadcast();
  static Stream<MessageDto> get messageStream => _messageStreamController.stream;

  static Future<void> initializeConnection(String profileId) async {
    _hubConnection =
        HubConnectionBuilder()
            .withUrl(
              '$baseUrl/chat?ProfileId=$profileId',
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

    _hubConnection.on('ReceiveMessage', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {

          final message = MessageDto.fromJson(arguments[0] as Map<String, dynamic>);

          _messageStreamController.add(message);
        } catch (e) {
          print('Erro ao converter mensagem: $e');
        }
      } else {
        print('Nenhuma mensagem recebida.');
      }
    });

    await _hubConnection.start();
    print('Conexão com o SignalR estabelecida.');
  }

  static Future<void> stopConnection() async {
    await _hubConnection.stop();
    print('Conexão com o SignalR encerrada.');
  }

  static Future<List<MessageDto>> getRecentMessagesAsync() async {
    var token = await AuthenticationService.getToken();
    var headers = createHeaders(token);

    var response = await http.get(
      Uri.parse('$baseUrl/v1/Chat/messages/getRecentMessages'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      List<MessageDto> messages = MessageDto.fromJsonList(jsonResponse);
      return messages;
    } else {
      throw Exception('Falha ao carregar mensagens recentes');
    }
  }

  static Future<List<MessageDto>> getMessagesAsync(String profileId, int page) async{
    var token = await AuthenticationService.getToken();
    var headers = createHeaders(token);

    var response = await http.get(
      Uri.parse('$baseUrl/v1/Chat/messages/getMessages/$profileId?page=$page'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      List<MessageDto> messages = MessageDto.fromJsonList(jsonResponse);
      return messages;
    } else {
      throw Exception('Falha ao carregar mensagens');
    }
  }

  static Future<void> sendMessageAsync(String profileId, String message) async {
    var token = await AuthenticationService.getToken();
    var headers = createHeaders(token);

    var body = jsonEncode({
      'receiverId': profileId,
      'message': message,
    });

    var response = await http.post(
      Uri.parse('$baseUrl/v1/Chat/messages/send'),
      headers: headers,
      body: body,
    );

    if (response.statusCode != 202) {
      throw Exception('Falha ao enviar mensagem');
    }
  }
}
