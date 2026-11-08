import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/theme.dart';
import 'config/api_config.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  ApiConfig.printCurrentConfig();
  runApp(const NusadhipaCourierApp());
}

class NusadhipaCourierApp extends StatelessWidget {
  const NusadhipaCourierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NUSA-DHIPA Kurir',
      debugShowCheckedModeBanner: false,
      theme: buildCourierTheme(),
      home: const SplashScreen(),
    );
  }
}
