import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/delivery.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';

class OrderDetailPage extends StatefulWidget {
  final Delivery delivery;

  const OrderDetailPage({super.key, required this.delivery});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final _api = ApiService();
  bool _isCompleting = false;

  String _formatRp(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  Future<void> _completeOrder() async {
    final delivery = widget.delivery;
    final orderLabel = delivery.orderNumber.isNotEmpty
        ? delivery.orderNumber
        : 'Delivery #${delivery.id}';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text(
          'Selesaikan Pengantaran?',
          style: TextStyle(color: textPrimary),
        ),
        content: Text(
          'Order $orderLabel akan ditandai selesai.',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('BATAL', style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('SELESAIKAN', style: TextStyle(color: brandRed)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCompleting = true);
    try {
      await _api.completeRoute(delivery.publicId);
      if (!mounted) return;
      _showSnackBar('Pengantaran $orderLabel selesai', courierGreen);
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      debugPrint('[OrderDetail] completeRoute ApiException: ${e.message}');
      if (!mounted) return;
      setState(() => _isCompleting = false);
      _showSnackBar('Pengantaran $orderLabel selesai (lokal)', courierGreen);
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('[OrderDetail] completeRoute error: $e');
      if (!mounted) return;
      setState(() => _isCompleting = false);
      _showSnackBar('Gagal: $e', brandRed);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final delivery = widget.delivery;
    final isCompleted = delivery.isCompleted;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: Text(
          delivery.orderNumber.isNotEmpty
              ? delivery.orderNumber
              : 'Order #${delivery.id}',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        backgroundColor: bgDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (isCompleted ? courierGreen : warningOrange)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isCompleted ? 'SELESAI' : 'PENDING',
                    style: TextStyle(
                      color: isCompleted ? courierGreen : warningOrange,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Informasi Penerima',
              children: [
                _buildRow(
                  Icons.person,
                  'Nama',
                  delivery.receiverName ?? delivery.buyerName,
                ),
                if (delivery.receiverPhone != null)
                  _buildRow(Icons.phone, 'Telepon', delivery.receiverPhone!),
              ],
            ),
            const SizedBox(height: 12),
            _buildCard(
              title: 'Alamat Pengiriman',
              children: [
                if (delivery.address != null)
                  _buildRow(Icons.location_on, 'Alamat', delivery.address!),
                if (delivery.city != null)
                  _buildRow(Icons.location_city, 'Kota', delivery.city!),
                if (delivery.province != null)
                  _buildRow(Icons.map, 'Provinsi', delivery.province!),
                if (delivery.postalCode != null)
                  _buildRow(
                    Icons.local_post_office,
                    'Kode Pos',
                    delivery.postalCode!,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCard(
              title: 'Detail Order',
              children: [
                _buildRow(
                  Icons.route,
                  'Jarak',
                  '${delivery.shippingDistanceKm.toStringAsFixed(1)} km',
                ),
                _buildRow(
                  Icons.attach_money,
                  'Total',
                  _formatRp(delivery.grandTotal),
                ),
                if (delivery.shippingLat != null &&
                    delivery.shippingLng != null)
                  _buildRow(
                    Icons.gps_fixed,
                    'Koordinat',
                    '${delivery.shippingLat!.toStringAsFixed(4)}, ${delivery.shippingLng!.toStringAsFixed(4)}',
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (!isCompleted) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Kembali ke halaman sebelumnya (Tab Rute di bottom nav)
                    Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: const Text(
                    'BUKA DI TAB RUTE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: courierBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isCompleting ? null : _completeOrder,
                  icon: _isCompleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle, color: Colors.white),
                  label: Text(
                    _isCompleting ? 'PROSES...' : 'SELESAIKAN PENGANTARAN',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: courierGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: courierGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: courierGreen.withValues(alpha: 0.5),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: courierGreen),
                    SizedBox(width: 8),
                    Text(
                      'PENGANTARAN SELESAI',
                      style: TextStyle(
                        color: courierGreen,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textMuted, size: 16),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
