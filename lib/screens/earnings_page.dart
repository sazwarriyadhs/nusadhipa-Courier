import 'package:flutter/material.dart';
import '../config/theme.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text('DOMPET KURIR', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        backgroundColor: bgDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card Saldo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: surfaceLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('SALDO TERSEDIA', style: TextStyle(color: textPrimary, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                    IconButton(
                      icon: Icon(_showBalance ? Icons.visibility : Icons.visibility_off, color: textMuted),
                      onPressed: () => setState(() => _showBalance = !_showBalance),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _showBalance ? 'Rp 850.000' : 'Rp ******',
                  style: const TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 20),
                const Text('PENDAPATAN TERTUNDA', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  _showBalance ? 'Rp 125.000' : 'Rp ******',
                  style: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('[ AJUKAN PENCAIRAN ]', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Transaksi Terbaru
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: surfaceLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TRANSAKSI TERBARU', style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                const SizedBox(height: 16),
                _TransactionItem(title: 'Pengantaran #001', amount: '+ Rp 25.000', color: courierGreen),
                const Divider(color: surfaceLight),
                _TransactionItem(title: 'Pengantaran #002', amount: '+ Rp 15.000', color: courierGreen),
                const Divider(color: surfaceLight),
                _TransactionItem(title: 'Pengantaran #003', amount: '+ Rp 5.000', color: courierGreen),
                const SizedBox(height: 16),
                const Center(
                  child: Text('lihat semua', style: TextStyle(color: textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  const _TransactionItem({required this.title, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('+ $title', style: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          Text(amount, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
