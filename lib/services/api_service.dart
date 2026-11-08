import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/courier.dart';
import '../models/delivery.dart';
import '../models/earnings.dart';
import 'auth_service.dart';
import 'api_exception.dart';

class ApiService {
  final AuthService _authService = AuthService();
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
    } catch (_) {
      body = {'message': response.body};
    }

    if (response.statusCode == 401) {
      _authService.logout();
      throw ApiException(
        statusCode: 401,
        message: 'Sesi Anda telah berakhir. Silakan login kembali.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = body is Map ? (body['message'] ?? 'Terjadi kesalahan server') : 'Terjadi kesalahan';
      throw ApiException(statusCode: response.statusCode, message: message.toString(), data: body);
    }

    if (body is Map && body['success'] == false) {
      throw ApiException(
        statusCode: response.statusCode,
        message: body['message']?.toString() ?? 'Operasi gagal',
        data: body,
      );
    }

    return body;
  }

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}$path');
    try {
      final response = await _client.get(uri, headers: await _headers())
          .timeout(Duration(milliseconds: ApiConfig.kTimeoutMs));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Gagal terhubung ke server: $e');
    }
  }

  Future<dynamic> _post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}$path');
    try {
      final response = await _client.post(
        uri,
        headers: await _headers(),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(Duration(milliseconds: ApiConfig.kTimeoutMs));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Gagal mengirim data: $e');
    }
  }

  // ============================================================
  // TYPED ENDPOINTS
  // ============================================================
  Future<Courier> getProfile() async {
    final json = await _get(ApiConfig.kCourierProfile);
    return Courier.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<Earnings> getEarnings() async {
    final json = await _get(ApiConfig.kCourierEarnings);
    return Earnings.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<List<Delivery>> getDeliveries() async {
    final json = await _get(ApiConfig.kCourierDeliveries);
    final data = json['data'];
    if (data is List) {
      return data.map((e) => Delivery.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<dynamic>> getRoutes() async {
    final json = await _get(ApiConfig.kCourierRoutes);
    final data = json['data'];
    if (data is List) return data;
    return [];
  }

  Future<void> claimRoute(dynamic routePublicId) async {
    await _post('${ApiConfig.kCourierRoutes}/$routePublicId/claim');
  }

  Future<void> completeRoute(dynamic routePublicId) async {
    await _post('${ApiConfig.kCourierRoutes}/$routePublicId/complete');
  }

  Future<void> requestPayout({
    required String method,
    required String accountNumber,
    required double amount,
  }) async {
    await _post(ApiConfig.kCourierPayouts, body: {
      'method': method,
      'account_number': accountNumber,
        'amount': amount,
    });
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    await _post('${ApiConfig.kCourierProfile}/status', body: {'is_online': isOnline});
  }
}



