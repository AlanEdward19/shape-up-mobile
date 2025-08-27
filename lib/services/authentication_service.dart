
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shape_up_app/dtos/authService/user_data.dart';
import 'package:shape_up_app/services/notification_service.dart';

class AuthenticationService
{
  static final String baseUrl = dotenv.env['AUTH_SERVICE_BASE_URL']!;
  static final storage = FlutterSecureStorage();

  static Map<String, String> createHeaders(String token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    return headers;
  }

  static Future<String> createAccountWithEmailAndPassword(String email, String password) async {
    final auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      var token = await userCredential.user!.getIdToken();

      return token!;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('A senha fornecida é muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        print('Já existe uma conta com este e-mail.');
      } else if (e.code == 'invalid-email') {
        print('O e-mail fornecido é inválido.');
      } else {
        print('Erro ao criar conta: ${e.message}');
      }
    } catch (e) {
      print('Erro inesperado: $e');
    }

    return '';
  }

  static Future<void> loginWithEmailAndPassword(String email, String password) async {
    final auth = FirebaseAuth.instance;

    var userCredentials = await auth.signInWithEmailAndPassword(email: email, password: password);
    var token = await userCredentials.user!.getIdToken();
    var userId = userCredentials.user!.uid;

    await saveToken(token!);
    await saveProfileId(userId);

    String? deviceToken = await FirebaseMessaging.instance.getToken();
    if (deviceToken != null) {
      await NotificationService.logIn(deviceToken);
    }

    NotificationService.initializeConnection(userId);
  }

  static Future<void> signOut() async {
    final auth = FirebaseAuth.instance;

    String? deviceToken = await FirebaseMessaging.instance.getToken();
    if (deviceToken != null) {
      await NotificationService.signOut(deviceToken);
    }

    await removeToken();
    await removeProfileId();
    await auth.signOut();

    NotificationService.stopConnection();
  }

  static Future<void> enhanceToken(UserData userData, String token) async{

    final response = await http.post(
      Uri.parse('$baseUrl/v1/Authentication/enhanceToken'),
      headers: createHeaders(token),
      body: jsonEncode({
        'scopes' : userData.toJson(),
      })
    );

    if (response.statusCode != 201) {
      throw Exception("Erro ao atualizar token do usuário");
    }
  }

  static Future<void> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception("Login com Google cancelado pelo usuário.");
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(credential);

      final String token = (await userCredential.user!.getIdToken())!;
      final String userId = userCredential.user!.uid;

      await saveToken(token);
      await saveProfileId(userId);

      String? deviceToken = await FirebaseMessaging.instance.getToken();
      if (deviceToken != null) {
        await NotificationService.logIn(deviceToken);
      }

      NotificationService.initializeConnection(userId);
    } catch (e) {
      print("Erro ao fazer login com Google: $e");
      rethrow;
    }
  }

  static Future<void> loginWithFacebook() async {
    final facebookProvider = FacebookAuthProvider();
    final auth = FirebaseAuth.instance;

    await auth.signInWithPopup(facebookProvider);
  }

  static Future<void> loginWithMicrosoft() async {
    final microsoftProvider = OAuthProvider('microsoft.com');
    final auth = FirebaseAuth.instance;

    await auth.signInWithPopup(microsoftProvider);
  }

  static Future<String> getToken({bool refreshToken = false}) async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user == null) {
      throw Exception("Usuário não autenticado.");
    }

    if (refreshToken) {
      final refreshedToken = await user.getIdToken(true);
      await saveToken(refreshedToken!);
      return refreshedToken;
    }

    // Check stored token validity
    final storedToken = await storage.read(key: 'auth_token');
    if (storedToken != null) {
      final payload = _decodeJwtPayload(storedToken);
      final expiration = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);

      if (DateTime.now().isBefore(expiration)) {
        return storedToken;
      }
    }

    // Fetch a new token if no valid stored token exists
    final newToken = await user.getIdToken();
    await saveToken(newToken!);
    return newToken;
  }

  static Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception("Token JWT inválido.");
    }

    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return json.decode(payload) as Map<String, dynamic>;
  }

  static Future<String> getProfileId() async{
    return (await storage.read(key: 'profile_id'))!;
  }

  static Future<void> removeToken() async{
    await storage.delete(key: 'auth_token');
  }

  static Future<void> removeProfileId() async{
    await storage.delete(key: 'profile_id');
  }

  static Future<void> saveToken(String token) async{
    await storage.write(key: 'auth_token', value: token);
  }

  static Future<void> saveProfileId(String profileId) async{
    await storage.write(key: 'profile_id', value: profileId);
  }
}