import 'package:flutter/material.dart';
import '../config/theme.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: Text('', style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: bgDark,
      ),
      body: const Center(
        child: Text(
          'Halaman ini sedang dalam pengembangan',
          style: TextStyle(color: textMuted),
        ),
      ),
    );
  }
}
