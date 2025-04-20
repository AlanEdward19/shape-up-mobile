
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shape_up_app/services/notification_service.dart';

class AuthenticationService
{
  static final storage = FlutterSecureStorage();

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

    await removeToken();
    await removeProfileId();
    await auth.signOut();

    String? deviceToken = await FirebaseMessaging.instance.getToken();
    if (deviceToken != null) {
      await NotificationService.signOut(deviceToken);
    }

    NotificationService.stopConnection();
  }

  static Future<void> loginWithGoogle() async {
    final googleProvider = GoogleAuthProvider();
    final auth = FirebaseAuth.instance;

    await auth.signInWithPopup(googleProvider);
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

  static Future<String> getToken() async{
    return (await storage.read(key: 'auth_token'))!;
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