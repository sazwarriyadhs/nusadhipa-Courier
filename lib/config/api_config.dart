import 'package:flutter/foundation.dart'
    show kIsWeb, kDebugMode, debugPrint, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  static const bool kUseProductionApi = bool.fromEnvironment(
    'USE_PROD',
    defaultValue: true,
  );

  static const String _productionBaseUrl = 'https://api.nusadhipa.shop';
  static const String _androidBaseUrl = 'http://10.0.2.2:4000';
  static const String _webBaseUrl = 'http://127.0.0.1:4000';
  static const String _otherBaseUrl = 'http://127.0.0.1:4000';

  static String get kApiBaseUrl {
    if (kUseProductionApi) return '$_productionBaseUrl/api/v1';
    if (kIsWeb) return '$_webBaseUrl/api/v1';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return '$_androidBaseUrl/api/v1';
    }
    return '$_otherBaseUrl/api/v1';
  }

  static const int kTimeoutMs = 30000;

  // Courier endpoints
  static const String kCourierLogin = '/courier/login';
  static const String kCourierRegister = '/courier/register';
  static const String kCourierProfile = '/courier/profile';
  static const String kCourierRoutes = '/courier/routes';
  static const String kCourierRoutesMine = '/courier/routes/mine';
  static const String kCourierEarnings = '/courier/earnings';
  static const String kCourierDeliveries = '/courier/deliveries';
  static const String kCourierPayouts = '/courier/payouts';

  static void printCurrentConfig() {
    if (!kDebugMode) return;
    debugPrint(
      '🔧 Courier ApiConfig: ${kUseProductionApi ? "PRODUCTION" : "LOCAL"}',
    );
    debugPrint('🔧 Base URL: $kApiBaseUrl');
  }
}
