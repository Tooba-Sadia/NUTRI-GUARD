import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleSignInService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  static Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        return account;
      }
      return null;
    } catch (error) {
      print('Google Sign-In Error: $error');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  static Future<Map<String, dynamic>?> signInAndSendToBackend() async {
    try {
      final account = await signInWithGoogle();
      if (account == null) {
        return null;
      }
      final auth = await account.authentication;

      final response = await http.post(
        Uri.parse(' https://db37-2407-d000-d-33c2-15fd-c4ba-2d0-db4d.ngrok-free.app'), // <-- your ngrok URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idToken': auth.idToken,
          'googleId': account.id,
          'name': account.displayName,
          'email': account.email,
          'photoUrl': account.photoUrl,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'Server error'};
      }
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }
}