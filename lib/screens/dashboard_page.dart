import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

// Import halaman modul (sesuai struktur folder)
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
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService().getUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: brandRed))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // --- HEADER SECTION ---
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/branding/kurir_cover.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: surfaceDark),
                        ),
                        Container(color: Colors.black.withOpacity(0.65)),
                        Positioned(
                          top: 60,
                          left: 20,
                          right: 20,
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: surfaceLight,
                                child: Icon(Icons.person, size: 40, color: textMuted),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Selamat datang,', style: TextStyle(color: textSecondary, fontSize: 12)),
                                    Text(
                                      _user?['name'] ?? 'NAMA KURIR',
                                      style: const TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => setState(() => _isOnline = !_isOnline),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _isOnline ? courierGreen.withOpacity(0.2) : surfaceLight,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: _isOnline ? courierGreen : textMuted),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.circle, color: _isOnline ? courierGreen : textMuted, size: 8),
                                            const SizedBox(width: 6),
                                            Text(
                                              _isOnline ? 'ONLINE' : 'OFFLINE',
                                              style: TextStyle(color: _isOnline ? courierGreen : textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                        // --- KARTU PENDAPATAN ---
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
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('TOTAL PENDAPATAN HARI INI', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Icon(Icons.remove_red_eye_outlined, color: brandRed, size: 20),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text('Rp 10.000', style: TextStyle(color: textPrimary, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
                              const SizedBox(height: 20),
                              const Row(
                                children: [
                                  Expanded(child: _StatItem(icon: Icons.check_circle, color: courierGreen, title: 'SELESAI', value: '0 PESANAN')),
                                  SizedBox(width: 16),
                                  Expanded(child: _StatItem(icon: Icons.access_time_filled, color: warningOrange, title: 'PENDING', value: 'Rp 0')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        // --- TOMBOL CARI PESANAN ---
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage()));
                            },
                            icon: const Icon(Icons.search, color: Colors.white),
                            label: const Text('CARI PESANAN SEKARANG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: brandRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- GRID MENU UTAMA ---
                        const Text('MENU UTAMA', style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        const SizedBox(height: 16),
                        
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.9,
                          children: [
                            _MenuIcon(icon: Icons.shopping_bag, label: 'ORDERS', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersPage()))),
                            _MenuIcon(icon: Icons.insights, label: 'PERFORMANCE', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerformancePage()))),
                            _MenuIcon(icon: Icons.camera_alt, label: 'PROOF', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeliveryProofPage()))),
                            _MenuIcon(icon: Icons.notifications, label: 'NOTIF', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()))),
                            _MenuIcon(icon: Icons.security, label: 'SECURITY', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPage()))),
                            _MenuIcon(icon: Icons.help_center, label: 'HELP', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage()))),
                            _MenuIcon(icon: Icons.smart_toy, label: 'AI ASSISTANT', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantPage()))),
                          ],
                        ),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  const _StatItem({required this.icon, required this.color, required this.title, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w900)),
          ],
        )
      ],
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuIcon({required this.icon, required this.label, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: surfaceLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: brandRed, size: 32),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
