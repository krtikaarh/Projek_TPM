import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user_session';
  static const String _isLoggedInKey = 'is_logged_in';

  // Enkripsi password menggunakan SHA256
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate session token
  static String _generateSession() {
    var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    var bytes = utf8.encode(timestamp);
    var digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  // Register user baru (username & password)
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Username dan password harus diisi',
        };
      }

      if (password != confirmPassword) {
        return {'success': false, 'message': 'Password tidak cocok'};
      }

      if (password.length < 6) {
        return {'success': false, 'message': 'Password minimal 6 karakter'};
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> usersJson = prefs.getStringList(_usersKey) ?? [];
      List<Map<String, dynamic>> users =
          usersJson
              .map((userStr) => json.decode(userStr) as Map<String, dynamic>)
              .toList();

      bool userExists = users.any((user) => user['username'] == username);

      if (userExists) {
        return {'success': false, 'message': 'Username sudah terdaftar'};
      }

      String hashedPassword = _hashPassword(password);
      Map<String, dynamic> newUser = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'username': username,
        'password': hashedPassword,
        'createdAt': DateTime.now().toIso8601String(),
      };

      users.add(newUser);
      List<String> updatedUsersJson =
          users.map((user) => json.encode(user)).toList();

      await prefs.setStringList(_usersKey, updatedUsersJson);

      return {'success': true, 'message': 'Registrasi berhasil'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Login user (username & password)
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Username dan password harus diisi',
        };
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> usersJson = prefs.getStringList(_usersKey) ?? [];
      List<Map<String, dynamic>> users =
          usersJson
              .map((userStr) => json.decode(userStr) as Map<String, dynamic>)
              .toList();

      String hashedPassword = _hashPassword(password);

      Map<String, dynamic>? user = users.firstWhere(
        (user) =>
            user['username'] == username && user['password'] == hashedPassword,
        orElse: () => {},
      );

      if (user.isEmpty) {
        return {'success': false, 'message': 'Username atau password salah'};
      }

      String sessionToken = _generateSession();
      Map<String, dynamic> sessionData = {
        'userId': user['id'],
        'username': user['username'],
        'sessionToken': sessionToken,
        'loginTime': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_currentUserKey, json.encode(sessionData));
      await prefs.setBool(_isLoggedInKey, true);

      return {
        'success': true,
        'message': 'Login berhasil',
        'user': sessionData,
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Ambil data user yang sedang login
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionStr = prefs.getString(_currentUserKey);

    if (sessionStr != null) {
      return json.decode(sessionStr) as Map<String, dynamic>;
    }
    return null;
  }

  // Logout user
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Cek validitas session (opsional, untuk keamanan tambahan)
  static Future<bool> isSessionValid() async {
    Map<String, dynamic>? user = await getCurrentUser();
    if (user == null) return false;

    // Cek apakah session sudah expired (misal 24 jam)
    DateTime loginTime = DateTime.parse(user['loginTime']);
    DateTime now = DateTime.now();
    Duration sessionDuration = now.difference(loginTime);

    // Session expired setelah 24 jam
    if (sessionDuration.inHours > 24) {
      await logout();
      return false;
    }

    return true;
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String email,
  }) async {
    try {
      Map<String, dynamic>? currentUser = await getCurrentUser();
      if (currentUser == null) {
        return {'success': false, 'message': 'User tidak ditemukan'};
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Ambil semua users
      List<String> usersJson = prefs.getStringList(_usersKey) ?? [];
      List<Map<String, dynamic>> users =
          usersJson
              .map((userStr) => json.decode(userStr) as Map<String, dynamic>)
              .toList();

      // Update user data
      for (int i = 0; i < users.length; i++) {
        if (users[i]['id'] == currentUser['userId']) {
          users[i]['username'] = username;
          users[i]['email'] = email;
          break;
        }
      }

      // Simpan perubahan
      List<String> updatedUsersJson =
          users.map((user) => json.encode(user)).toList();

      await prefs.setStringList(_usersKey, updatedUsersJson);

      // Update session data
      currentUser['username'] = username;
      currentUser['email'] = email;
      await prefs.setString(_currentUserKey, json.encode(currentUser));

      return {'success': true, 'message': 'Profile berhasil diupdate'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
