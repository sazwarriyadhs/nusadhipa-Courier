import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {
  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    final headers = <String, String>{'Accept': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}$path');
    try {
      final response = await http
          .get(uri, headers: await _headers())
          .timeout(Duration(milliseconds: ApiConfig.kTimeoutMs));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Gagal memuat data: $e');
    }
  }

  Future<Map<String, dynamic>> _post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConfig.kApiBaseUrl}$path');
    try {
      final response = await http
          .post(
            uri,
            headers: {
              ...await _headers(),
              'Content-Type': 'application/json',
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(Duration(milliseconds: ApiConfig.kTimeoutMs));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Gagal mengirim data: $e');
    }
  }

  // Helper: ambil 'data' dan pastiin bentuknya Map
  Map<String, dynamic> _extractMap(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return data.first as Map<String, dynamic>;
    }
    return {};
  }

  // Helper: ambil 'data' dan pastiin bentuknya List
  List<dynamic> _extractList(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is List) return data;
    if (data is Map<String, dynamic>) return [data];
    return [];
  }

  Future<Map<String, dynamic>> getProfile() async {
    final json = await _get(ApiConfig.kCourierProfile);
    return _extractMap(json);
  }

  Future<Map<String, dynamic>> getRoutes() async {
    final json = await _get(ApiConfig.kCourierRoutes);
    return json;
  }

  Future<Map<String, dynamic>> getMyRoutes() async {
    final json = await _get(ApiConfig.kCourierRoutesMine);
    return json;
  }

  Future<Map<String, dynamic>> getEarnings() async {
    final json = await _get(ApiConfig.kCourierEarnings);
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    return {};
  }

  Future<Map<String, dynamic>> getDeliveries() async {
    final json = await _get(ApiConfig.kCourierDeliveries);
    return json;
  }

  // Helper buat dipanggil dari screen (routes_page, deliveries_page)
  Future<List<dynamic>> getRoutesList() async {
    final json = await getRoutes();
    return _extractList(json);
  }

  Future<List<dynamic>> getDeliveriesList() async {
    final json = await getDeliveries();
    return _extractList(json);
  }

  // ============================================================
  // CLAIM RUTE (Ambil tugas pengantaran)
  // ============================================================
  Future<void> claimRoute(dynamic routeId) async {
    final path = '${ApiConfig.kCourierRoutes}/$routeId/claim';
    await _post(path);
  }

  // ============================================================
  // COMPLETE RUTE (Selesaikan pengantaran)
  // ============================================================
  Future<void> completeRoute(dynamic routeId) async {
    final path = '${ApiConfig.kCourierRoutes}/$routeId/complete';
    await _post(path);
  }
  Future<void> requestPayout({
    required String method,
    required String accountNumber,
  }) async {
    final path = ApiConfig.kCourierPayouts;
    await _post(path, body: {'method': method, 'account_number': accountNumber});
  }

}

class EarningsResult {
  final double total;
  final double pending;
  final double paid;
  final List<dynamic> history;

  EarningsResult({
    required this.total,
    required this.pending,
    required this.paid,
    this.history = const [],
  });

  factory EarningsResult.fromJson(Map<String, dynamic> json) {
    return EarningsResult(
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      pending: double.tryParse(json['pending']?.toString() ?? '0') ?? 0,
      paid: double.tryParse(json['paid']?.toString() ?? '0') ?? 0,
      history: json['history'] as List<dynamic>? ?? [],
    );
  }

  // Getter buat UI
  double get availableBalance => total - pending - paid;
  double get pendingBalance => pending;
  double get totalPaid => paid;
}

