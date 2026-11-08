import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/courier.dart';
import '../models/earnings.dart';
import '../models/delivery.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';
import 'orders_page.dart';
import 'performance_page.dart';
import 'delivery_proof_page.dart';
import 'notifications_page.dart';
import 'security_page.dart';
import 'help_center_page.dart';
import 'ai_assistant_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _api = ApiService();
  Courier? _courier;
  Earnings? _earnings;
  List<Delivery> _deliveries = [];
  bool _isLoading = true;
  bool _isOnline = false;
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
      final results = await Future.wait([
        _api.getProfile(),
        _api.getEarnings(),
        _api.getDeliveries(),
      ]);

      if (mounted) {
        setState(() {
          _courier = results[0] as Courier;
          _earnings = results[1] as Earnings;
          _deliveries = results[2] as List<Delivery>;
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _isLoading = false;
        });
        if (e.statusCode == 401) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data: $e';
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgDark,
        body: Center(child: CircularProgressIndicator(color: brandRed)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: bgDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: brandRed, size: 64),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: textPrimary)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
              ],
            ),
          ),
        ),
      );
    }

    final completedCount = _deliveries.where((d) => d.isCompleted).length;

    return Scaffold(
      backgroundColor: bgDark,
      body: RefreshIndicator(
        color: brandRed,
        backgroundColor: surfaceDark,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // HEADER
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/branding/kurir_cover.jpg', fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) => Container(color: surfaceDark)),
                    Container(color: Colors.black.withOpacity(0.65)),
                    Positioned(
                      top: 60, left: 20, right: 20,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: surfaceLight,
                            backgroundImage: _courier?.photoUrl != null && _courier!.photoUrl!.isNotEmpty
                                ? NetworkImage(_courier!.photoUrl!)
                                : null,
                            child: _courier?.photoUrl == null || _courier!.photoUrl!.isEmpty
                                ? const Icon(Icons.person, size: 40, color: textMuted)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Selamat datang,', style: TextStyle(color: textSecondary, fontSize: 12)),
                                Text(_courier?.name ?? 'KURIR',
                                    style: const TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(children: [
                                  _StatusPill(isOnline: _isOnline, onTap: () {
                                    setState(() => _isOnline = !_isOnline);
                                    _api.updateOnlineStatus(_isOnline).catchError((_) {});
                                  }),
                                  const SizedBox(width: 8),
                                  if (_courier?.isApproved == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: courierGreen.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: courierGreen),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.verified, color: courierGreen, size: 10),
                                          SizedBox(width: 4),
                                          Text('VERIFIED', style: TextStyle(color: courierGreen, fontSize: 9, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KARTU PENDAPATAN
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
                          const Text('TOTAL PENDAPATAN',
                              style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(_formatRp(_earnings?.total ?? 0),
                              style: const TextStyle(color: textPrimary, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
                          const SizedBox(height: 4),
                          Text('Saldo tersedia: ${_formatRp(_earnings?.balance ?? 0)}',
                              style: const TextStyle(color: textMuted, fontSize: 12)),
                          const SizedBox(height: 20),
                          Row(children: [
                            Expanded(child: _StatItem(icon: Icons.check_circle, color: courierGreen,
                                title: 'SELESAI', value: '$completedCount PESANAN')),
                            const SizedBox(width: 16),
                            Expanded(child: _StatItem(icon: Icons.access_time_filled, color: warningOrange,
                                title: 'PENDING', value: _formatRp(_earnings?.pending ?? 0))),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // TOMBOL CARI PESANAN (Warna Solid)
                    SizedBox(
                      width: double.infinity, height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage())),
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: const Text('CARI PESANAN SEKARANG',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandRed,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text('MENU UTAMA',
                        style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 3, shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.0,
                      children: [
                        _MenuIcon(icon: Icons.shopping_bag, label: 'ORDERS',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage()))),
                        _MenuIcon(icon: Icons.insights, label: 'PERFORMANCE',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerformancePage()))),
                        _MenuIcon(icon: Icons.camera_alt, label: 'PROOF',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryProofPage()))),
                        _MenuIcon(icon: Icons.notifications, label: 'NOTIF',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()))),
                        _MenuIcon(icon: Icons.security, label: 'SECURITY',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPage()))),
                        _MenuIcon(icon: Icons.help_center, label: 'HELP',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()))),
                        _MenuIcon(icon: Icons.smart_toy, label: 'AI',
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantPage()))),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onTap;
  const _StatusPill({required this.isOnline, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isOnline ? courierGreen.withOpacity(0.2) : surfaceLight,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isOnline ? courierGreen : textMuted),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.circle, color: isOnline ? courierGreen : textMuted, size: 8),
          const SizedBox(width: 6),
          Text(isOnline ? 'ONLINE' : 'OFFLINE',
              style: TextStyle(color: isOnline ? courierGreen : textMuted,
                  fontSize: 10, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon; final Color color; final String title; final String value;
  const _StatItem({required this.icon, required this.color, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w900)),
      ]),
    ]);
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _MenuIcon({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceDark, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: surfaceLight),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: brandRed, size: 32),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: textSecondary, fontSize: 10,
              fontWeight: FontWeight.bold, letterSpacing: 0.5), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}




