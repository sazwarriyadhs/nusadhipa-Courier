import 'package:flutter/material.dart';
import '../config/theme.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text('DAFTAR PESANAN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        backgroundColor: bgDark,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: brandRed), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Section
          Row(
            children: [
              Expanded(child: _FilterChip(label: 'Terdekat', icon: Icons.location_on, isSelected: true)),
              const SizedBox(width: 8),
              Expanded(child: _FilterChip(label: 'Berat', icon: Icons.scale, isSelected: false)),
              const SizedBox(width: 8),
              Expanded(child: _FilterChip(label: 'Pendapatan', icon: Icons.money, isSelected: false)),
            ],
          ),
          const SizedBox(height: 20),

          // List Pesanan (Dummy)
          _OrderCard(
            id: '#ND-000125',
            tenant: 'Tenant A',
            customer: 'Customer B',
            distance: '5.2 km',
            weight: '2 kg',
            price: 'Rp 25.000',
            onClaim: () {},
          ),
          const SizedBox(height: 16),
          _OrderCard(
            id: '#ND-000126',
            tenant: 'Tenant C',
            customer: 'Customer D',
            distance: '3.1 km',
            weight: '1 kg',
            price: 'Rp 15.000',
            onClaim: () {},
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  const _FilterChip({required this.label, required this.icon, required this.isSelected});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected ? brandRed.withOpacity(0.2) : surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? brandRed : surfaceLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? brandRed : textMuted, size: 16),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: isSelected ? brandRed : textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final String id, tenant, customer, distance, weight, price;
  final VoidCallback onClaim;

  const _OrderCard({
    required this.id, required this.tenant, required this.customer,
    required this.distance, required this.weight, required this.price, required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(id, style: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: warningOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: const Text('TERSEDIA', style: TextStyle(color: warningOrange, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.store, color: textMuted, size: 16),
              const SizedBox(width: 8),
              Text('Pickup: $tenant', style: const TextStyle(color: textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.person, color: textMuted, size: 16),
              const SizedBox(width: 8),
              Text('Delivery: $customer', style: const TextStyle(color: textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoBadge(icon: Icons.route, text: distance),
              _InfoBadge(icon: Icons.scale, text: weight),
              Text(price, style: const TextStyle(color: courierGreen, fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: brandRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('AMBIL PESANAN', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoBadge({required this.icon, required this.text});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: textMuted, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: textSecondary, fontSize: 12)),
      ],
    );
  }
}
