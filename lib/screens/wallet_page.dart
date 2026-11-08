import 'package:flutter/material.dart';
import '../config/theme.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: Text('', style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: bgDark,
      ),
      body: const Center(
        child: Text('Halaman ini sedang dalam pengembangan', style: TextStyle(color: textMuted)),
      ),
    );
  }
}
