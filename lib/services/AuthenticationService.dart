import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthenticationService
{
  static final storage = FlutterSecureStorage();

  static Future<void> loginWithEmailAndPassword(String email, String password) async {
    final auth = FirebaseAuth.instance;

    var userCredentials = await auth.signInWithEmailAndPassword(email: email, password: password);
    var token = await userCredentials.user!.getIdToken();

    await saveToken(token!);
  }

  static Future<void> signOut() async {
    final auth = FirebaseAuth.instance;

    await removeToken();
    await auth.signOut();
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

  static Future<void> removeToken() async{
    await storage.delete(key: 'auth_token');
  }

  static Future<void> saveToken(String token) async{
    await storage.write(key: 'auth_token', value: token);
  }
}