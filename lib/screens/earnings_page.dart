import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/earnings.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  final _api = ApiService();
  Earnings? _earnings;
  bool _isLoading = true;
  String? _error;
  bool _showBalance = true;

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
      final earnings = await _api.getEarnings();
      if (mounted) {
        setState(() {
          _earnings = earnings;
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
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  void _showPayoutSheet() {
    if ((_earnings?.balance ?? 0) < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo minimal untuk pencairan adalah Rp 10.000'),
          backgroundColor: warningOrange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PayoutSheet(
        balance: _earnings?.balance ?? 0,
        onSuccess: () {
          Navigator.pop(context);
          _loadData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permintaan pencairan berhasil dikirim!'),
              backgroundColor: courierGreen,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text(
          'DOMPET KURIR',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        backgroundColor: bgDark,
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
        padding: const EdgeInsets.all(16),
        children: [
          _buildSaldoCard(),
          const SizedBox(height: 24),
          _buildTransaksiCard(),
        ],
      ),
    );
  }

  Widget _buildSaldoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [surfaceDark, surfaceDark.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
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
                  color: brandRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SALDO TERSEDIA',
                  style: TextStyle(color: brandRed, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              IconButton(
                icon: Icon(_showBalance ? Icons.visibility : Icons.visibility_off, color: textMuted),
                onPressed: () => setState(() => _showBalance = !_showBalance),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _showBalance ? _formatRp(_earnings?.balance ?? 0) : 'Rp ******',
            style: const TextStyle(color: textPrimary, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Text(
            'Pendapatan tertunda: ${_formatRp(_earnings?.pending ?? 0)}',
            style: const TextStyle(color: textMuted, fontSize: 12),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _showPayoutSheet,
              icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
              label: const Text(
                'AJUKAN PENCAIRAN',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransaksiCard() {
    final history = _earnings?.history ?? [];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRANSAKSI TERBARU',
            style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 16),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Belum ada transaksi', style: TextStyle(color: textMuted, fontSize: 13)),
              ),
            )
          else
            ...history.map(
              (h) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(h.orderNumber, style: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('+ ${_formatRp(h.amount)}', style: const TextStyle(color: courierGreen, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Divider(color: surfaceLight),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// WOW VERSION: BOTTOM SHEET PENCAIRAN
// ============================================================
class PayoutSheet extends StatefulWidget {
  final double balance;
  final VoidCallback onSuccess;

  const PayoutSheet({super.key, required this.balance, required this.onSuccess});

  @override
  State<PayoutSheet> createState() => _PayoutSheetState();
}

class _PayoutSheetState extends State<PayoutSheet> {
  final _api = ApiService();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedMethod = 'bank';
  bool _isLoading = false;
  String? _error;

  static const _methods = [
    {'id': 'bank_transfer', 'label': 'Bank Transfer', 'icon': Icons.account_balance},
    {'id': 'ewallet', 'label': 'E-Wallet', 'icon': Icons.wallet},
  ];

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatRp(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }

  Future<void> _submit() async {
    final account = _accountController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;

    if (account.isEmpty) {
      setState(() => _error = 'Nomor rekening wajib diisi');
      return;
    }
    if (amount < 10000) {
      setState(() => _error = 'Minimal pencairan Rp 10.000');
      return;
    }
    if (amount > widget.balance) {
      setState(() => _error = 'Saldo tidak mencukupi');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // PASTIKAN: Endpoint /courier/payouts ada di backend
      await _api.requestPayout(
        method: _selectedMethod,
        accountNumber: account,
        amount: amount,
      );
      if (mounted) widget.onSuccess();
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
          _error = 'Gagal: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    const double adminFee = 2500.0;
    final double totalReceived = amount > 0 ? amount - adminFee : 0.0;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: brandRed, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ajukan Pencairan',
                    style: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Saldo tersedia: ${_formatRp(widget.balance)}',
              style: const TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Metode
            const Text('Metode Pencairan', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: _methods.map((m) {
                final selected = _selectedMethod == m['id'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = m['id'] as String),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? brandRed.withValues(alpha: 0.2) : surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? brandRed : surfaceLight),
                      ),
                      child: Column(
                        children: [
                          Icon(m['icon'] as IconData, color: selected ? brandRed : textMuted),
                          const SizedBox(height: 4),
                          Text(
                            m['label'] as String,
                            style: TextStyle(color: selected ? brandRed : textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Rekening
            const Text('Nomor Rekening / E-Wallet', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _accountController,
              style: const TextStyle(color: textPrimary),
              decoration: InputDecoration(
                hintText: _selectedMethod == 'bank' ? 'Contoh: BCA 1234567890' : 'Contoh: 081234567890',
                hintStyle: const TextStyle(color: textMuted),
                prefixIcon: const Icon(Icons.pin, color: textMuted),
                filled: true,
                fillColor: surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Nominal
            const Text('Nominal Pencairan', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w900),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Min. Rp 10.000',
                hintStyle: const TextStyle(color: textMuted),
                prefixIcon: const Icon(Icons.money, color: textMuted),
                filled: true,
                fillColor: surfaceLight,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            // Preview
            if (amount > 0) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _previewRow('Nominal', _formatRp(amount)),
                    const SizedBox(height: 8),
                    _previewRow('Biaya Admin', _formatRp(adminFee)),
                    const Divider(color: surfaceLight, height: 24),
                    _previewRow(
                      'Total Diterima',
                      _formatRp(totalReceived),
                      isBold: true,
                      color: courierGreen,
                    ),
                  ],
                ),
              ),
            ],

            // Error
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: brandRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: brandRed, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(color: textPrimary, fontSize: 12))),
                  ],
                ),
              ),
            ],

            // Tombol Submit
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('AJUKAN SEKARANG', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: textSecondary, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: color ?? textPrimary,
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}


