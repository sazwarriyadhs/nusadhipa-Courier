import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'dashboard_page.dart';
import 'routes_page.dart';
import 'earnings_page.dart';
import 'profile_page.dart';

class CourierShell extends StatefulWidget {
  const CourierShell({super.key});

  @override
  State<CourierShell> createState() => _CourierShellState();
}

class _CourierShellState extends State<CourierShell> {
  int selectedIndex = 0;

  final pages = const [
    DashboardPage(),
    RoutesPage(),
    EarningsPage(),
    ProfilePage(),
  ];

  final labels = const ['Beranda', 'Rute', 'Dompet', 'Profil'];

  final icons = const [
    Icons.home_rounded,
    Icons.map_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: surfaceDark,
          border: Border(top: BorderSide(color: surfaceLight, width: 1)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(
              children: List.generate(
                labels.length,
                (i) => Expanded(
                  child: _NavItem(
                    icon: icons[i],
                    label: labels[i],
                    selected: selectedIndex == i,
                    onTap: () => setState(() => selectedIndex = i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: brandRed.withOpacity(0.2),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: selected ? 40 : 0,
            decoration: BoxDecoration(
              color: brandRed,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Icon(icon, color: selected ? brandRed : textMuted, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: selected ? textPrimary : textMuted,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
