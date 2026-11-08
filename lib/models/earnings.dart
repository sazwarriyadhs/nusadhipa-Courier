class Earnings {
  final double balance;  // Saldo tersedia
  final double pending;  // Pendapatan tertunda
  final double total;    // Total pendapatan keseluruhan
  final List<EarningHistory> history;

  Earnings({
    required this.balance,
    required this.pending,
    required this.total,
    this.history = const [],
  });

  factory Earnings.fromJson(Map<String, dynamic> json) {
    return Earnings(
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      pending: double.tryParse(json['pending']?.toString() ?? '0') ?? 0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      history: (json['history'] as List<dynamic>?)
              ?.map((e) => EarningHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class EarningHistory {
  final int id;
  final String orderNumber;
  final double amount;
  final DateTime? createdAt;

  EarningHistory({
    required this.id,
    required this.orderNumber,
    required this.amount,
    this.createdAt,
  });

  factory EarningHistory.fromJson(Map<String, dynamic> json) {
    return EarningHistory(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
