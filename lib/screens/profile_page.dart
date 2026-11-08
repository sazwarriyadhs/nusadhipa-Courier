import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/courier.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';
import '../services/auth_service.dart';
import 'security_page.dart';
import 'help_center_page.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _api = ApiService();
  Courier? _courier;
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
      final courier = await _api.getProfile();
      if (mounted) {
        setState(() {
          _courier = courier;
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

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text(
          'PROFIL KURIR',
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
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: textPrimary)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: brandRed,
      backgroundColor: surfaceDark,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- HEADER PROFIL (FOTO) ---
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: surfaceLight,
                      backgroundImage: _courier?.photoUrl != null && _courier!.photoUrl!.isNotEmpty
                          ? NetworkImage(_courier!.photoUrl!)
                          : null,
                      child: _courier?.photoUrl == null || _courier!.photoUrl!.isEmpty
                          ? const Icon(Icons.person, size: 60, color: textMuted)
                          : null,
                    ),
                    if (_courier?.isApproved == true)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: courierGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _courier?.name ?? 'NAMA KURIR',
                  style: const TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  _courier?.email ?? 'email@domain.com',
                  style: const TextStyle(color: textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 8),
                if (_courier?.isApproved == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: brandRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: brandRed),
                    ),
                    child: const Text(
                      'VERIFIED COURIER',
                      style: TextStyle(color: brandRed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // --- INFORMASI AKUN ---
          const Text('INFORMASI AKUN',
              style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),
          _ProfileCard(
            children: [
              _ProfileItem(icon: Icons.phone, label: 'Nomor Telepon', value: _courier?.phone ?? '-'),
              const Divider(color: surfaceLight),
              _ProfileItem(icon: Icons.location_city, label: 'Kota Operasional', value: _courier?.city ?? '-'),
              const Divider(color: surfaceLight),
              _ProfileItem(icon: Icons.location_on, label: 'Alamat', value: _courier?.address ?? '-'),
              const Divider(color: surfaceLight),
              _ProfileItem(icon: Icons.motorcycle, label: 'Kendaraan', value: _courier?.vehicleType ?? '-'),
              const Divider(color: surfaceLight),
              _ProfileItem(icon: Icons.pin, label: 'Plat Nomor', value: _courier?.plateNumber ?? '-'),
            ],
          ),

          const SizedBox(height: 24),

          // --- MENU PENGATURAN ---
          const Text('PENGATURAN',
              style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),
          _ProfileCard(
            children: [
              _MenuTile(
                icon: Icons.security,
                title: 'Keamanan & Privasi',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPage())),
              ),
              const Divider(color: surfaceLight),
              _MenuTile(
                icon: Icons.help_center,
                title: 'Pusat Bantuan',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterPage())),
              ),
              const Divider(color: surfaceLight),
              _MenuTile(icon: Icons.description, title: 'Syarat & Ketentuan', onTap: () {}),
            ],
          ),

          const SizedBox(height: 32),

          // --- TOMBOL LOGOUT ---
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: brandRed),
              label: const Text('KELUAR AKUN',
                  style: TextStyle(color: brandRed, fontWeight: FontWeight.w900, letterSpacing: 1)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: brandRed),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// --- WIDGET PENDUKUNG ---

class _ProfileCard extends StatelessWidget {
  final List<Widget> children;
  const _ProfileCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surfaceLight),
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: brandRed, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: textSecondary, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
