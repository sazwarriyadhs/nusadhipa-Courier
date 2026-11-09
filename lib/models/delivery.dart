import 'dart:convert';

class Delivery {
  final int id;
  final String publicId;
  final String orderNumber;
  final double grandTotal;
  final double shippingDistanceKm;
  final double? shippingLat;
  final double? shippingLng;
  final String claimStatus; // 'pending', 'completed'
  final String status;
  final String buyerName;

  // Parsed dari shipping_address (JSON string)
  final String? receiverName;
  final String? receiverPhone;
  final String? address;
  final String? city;
  final String? province;
  final String? postalCode;

  Delivery({
    required this.id,
    required this.publicId,
    required this.orderNumber,
    required this.grandTotal,
    required this.shippingDistanceKm,
    this.shippingLat,
    this.shippingLng,
    required this.claimStatus,
    required this.status,
    required this.buyerName,
    this.receiverName,
    this.receiverPhone,
    this.address,
    this.city,
    this.province,
    this.postalCode,
  });

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';

  factory Delivery.fromJson(Map<String, dynamic> json) {
    // Parse shipping_address JSON string
    Map<String, dynamic>? addressData;
    final rawAddress = json['shipping_address'];
    if (rawAddress is String && rawAddress.isNotEmpty) {
      try {
        addressData = jsonDecode(rawAddress) as Map<String, dynamic>;
      } catch (_) {}
    } else if (rawAddress is Map<String, dynamic>) {
      addressData = rawAddress;
    }

    return Delivery(
      id: json['id'] ?? 0,
      publicId: json['public_id'] ?? '',
      orderNumber: json['order_number'] ?? '',
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0,
      shippingDistanceKm:
          double.tryParse(json['shipping_distance_km']?.toString() ?? '0') ?? 0,
      shippingLat: double.tryParse(json['shipping_lat']?.toString() ?? ''),
      shippingLng: double.tryParse(json['shipping_lng']?.toString() ?? ''),
      claimStatus: json['claim_status'] ?? 'pending',
      status: json['status'] ?? 'pending',
      buyerName: json['buyer_name'] ?? '',
      receiverName: addressData?['name'],
      receiverPhone: addressData?['phone'],
      address: addressData?['address'],
      city: addressData?['city'],
      province: addressData?['province'],
      postalCode: addressData?['postal_code'],
    );
  }
}
