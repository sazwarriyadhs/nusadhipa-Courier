import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AppColors {
  static const Color primaryRed = Color(0xFFF50016);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F7F8);
  static const Color textDark = Color(0xFF202124);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color successGreen = Color(0xFF10B981);
  static const Color border = Color(0xFFE5E7EB);
  static const Color orange = Color(0xFFF59E0B);
}

class DeliveriesPage extends StatefulWidget {
  const DeliveriesPage({super.key});

  @override
  State<DeliveriesPage> createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {
  bool _loading = true;
  String? _error;
  List<dynamic> _deliveries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final deliveries = await ApiService().getDeliveriesList();
      setState(() { _deliveries = deliveries; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _formatRupiah(dynamic value) {
    final num = double.tryParse(value?.toString() ?? '0') ?? 0;
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(num);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primaryRed));
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, color: AppColors.primaryRed, size: 52),
              const SizedBox(height: 12),
              const Text('Gagal memuat pengiriman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, foregroundColor: Colors.white),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pengiriman Saya', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
              const SizedBox(height: 4),
              const Text('Daftar order yang sedang kamu antar.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              if (_deliveries.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Belum ada pengiriman.', style: TextStyle(color: AppColors.textMuted))),
                )
              else
                ..._deliveries.map((d) => _buildDeliveryCard(d)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(dynamic d) {
    final status = (d['status'] ?? 'paid').toString().toLowerCase();
    final claimStatus = (d['claim_status'] ?? 'taken').toString().toLowerCase();
    final isTaken = claimStatus == 'taken';
    final isCompleted = claimStatus == 'completed';

    final statusLabel = isCompleted ? 'Selesai' : (isTaken ? 'Sedang Diantar' : status);
    final statusColor = isCompleted ? AppColors.successGreen : (isTaken ? AppColors.orange : AppColors.primaryRed);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order Number & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d['order_number']?.toString() ?? 'ORD-XXX', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(statusLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(d['buyer_name']?.toString() ?? 'Pembeli', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Alamat
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.primaryRed),
              const SizedBox(width: 6),
              Expanded(
                child: Text(d['shipping_address']?.toString() ?? '-', style: const TextStyle(fontSize: 11, color: AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Jarak & Total
          Row(
            children: [
              const Icon(Icons.near_me, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('${d['shipping_distance_km'] ?? '-'} km', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const Spacer(),
              Text(_formatRupiah(d['grand_total'] ?? 0), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryRed)),
            ],
          ),
          const SizedBox(height: 16),

          // Tombol Selesaikan
          if (isTaken)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await ApiService().completeRoute(d['id']);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Pengantaran selesai!')),
                      );
                      _load();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Gagal selesaikan: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('SELESAIKAN PENGANTARAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}