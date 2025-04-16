import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MessageDecryptor {
  static String decryptMessage(String encryptedMessage) {
    final encryptionKey = dotenv.env['CHAT_ENCRYPTION_KEY']!;

    final key = sha256.convert(utf8.encode(encryptionKey)).bytes;

    final iv = encrypt.IV(Uint8List(16));

    final encrypter = encrypt.Encrypter(encrypt.AES(
      encrypt.Key(Uint8List.fromList(key)),
      mode: encrypt.AESMode.cbc,
    ));

    String decryptedMessage = encrypter.decrypt64(encryptedMessage, iv: iv);
    var decryptedMessageArray = decryptedMessage.split(' ');
    final decrypted = decryptedMessageArray.sublist(0, decryptedMessageArray.length - 2);
    return decrypted.join(' ');
  }
}