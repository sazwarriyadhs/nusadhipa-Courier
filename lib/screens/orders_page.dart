import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/delivery.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _api = ApiService();
  List<Delivery> _deliveries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final deliveries = await _api.getDeliveries();
      if (mounted) {
        setState(() {
          _deliveries = deliveries;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _formatRp(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text(
          'DAFTAR PESANAN',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        backgroundColor: bgDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: brandRed),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: brandRed));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: brandRed, size: 64),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: textPrimary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_deliveries.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, color: textMuted, size: 64),
            SizedBox(height: 16),
            Text('Belum ada pesanan', style: TextStyle(color: textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: brandRed,
      backgroundColor: surfaceDark,
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _deliveries.length,
        separatorBuilder: (_, index) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final delivery = _deliveries[i];
          return _DeliveryCard(
            delivery: delivery,
            formatRp: _formatRp,
            onTap: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailPage(delivery: delivery),
                ),
              );

              // Jika halaman detail menandai selesai (return true)
              if (result == true && mounted) {
                // Hapus dari daftar lokal agar langsung hilang dari tampilan
                // meskipun backend belum meng-update datanya.
                setState(() {
                  _deliveries.removeWhere((d) => d.id == delivery.id);
                });
              }
            },
          );
        },
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final String Function(double) formatRp;
  final VoidCallback onTap;

  const _DeliveryCard({
    required this.delivery,
    required this.formatRp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = delivery.isCompleted ? courierGreen : warningOrange;
    final statusText = delivery.isCompleted ? 'SELESAI' : 'PENDING';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                  Expanded(
                    child: Text(
                      delivery.orderNumber,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, color: textMuted, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery.buyerName,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: textMuted, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery.city ?? '-',
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.route, color: textMuted, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${delivery.shippingDistanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatRp(delivery.grandTotal),
                    style: const TextStyle(
                      color: courierGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
