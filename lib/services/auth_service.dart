import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static const _tokenKey = 'courier_token';
  static const _userKey = 'courier_user';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}${ApiConfig.kCourierLogin}');
    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(Duration(milliseconds: ApiConfig.kTimeoutMs));

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Respons kosong dari server.'};
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return {'success': false, 'message': 'Format respons tidak valid.'};
      }

      if (response.statusCode != 200 || decoded['success'] != true) {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Login gagal.',
        };
      }

      final token = decoded['token'] as String?;
      final user = decoded['data'] as Map<String, dynamic>?;

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan di respons.',
        };
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, jsonEncode(user ?? {'email': email}));

      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.kApiBaseUrl}${ApiConfig.kCourierRegister}',
    );
    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'email': email,
              'phone': phone,
              'password': password,
            }),
          )
          .timeout(Duration(milliseconds: ApiConfig.kTimeoutMs));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          'success': false,
          'message': data['message'] ?? 'Register gagal.',
        };
      }
      return {
        'success': true,
        'message': data['message'] ?? 'Registrasi berhasil.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
