import 'package:mysql1/mysql1.dart';

class DatabaseHelper {
  static Future<MySqlConnection> _connect() async {
    return await MySqlConnection.connect(
      ConnectionSettings(
        host: '172.29.192.1', // For emulator (use 'localhost' for web)
        port: 3306,
        user: 'flutter_user',
        password: 'FlutterPass123!',
        db: 'flutter_auth',
      ),
    );
  }

  static Future<void> signUp(String username, String email, String password) async {
    final conn = await _connect();
    await conn.query(
      'INSERT INTO users (username, email, password) VALUES (?, ?, ?)',
      [username, email, password],
    );
    await conn.close();
  }

  static Future<bool> login(String username, String password) async {
    final conn = await _connect();
    final results = await conn.query(
      'SELECT * FROM users WHERE username = ? AND password = ?',
      [username, password],
    );
    await conn.close();
    return results.isNotEmpty;
  }
}