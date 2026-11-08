class Courier {
  final int id;
  final String publicId;
  final String name;
  final String email;
  final String? phone;
  final String? vehicleType;
  final String partnershipType;
  final String? plateNumber;
  final String? city;
  final String? address;      // BARU
  final String? photoUrl;     // BARU
  final String? payoutMethod;
  final String? payoutAccount;
  final String status;

  Courier({
    required this.id,
    required this.publicId,
    required this.name,
    required this.email,
    this.phone,
    this.vehicleType,
    required this.partnershipType,
    this.plateNumber,
    this.city,
    this.address,
    this.photoUrl,
    this.payoutMethod,
    this.payoutAccount,
    required this.status,
  });

  bool get isApproved => status == 'approved';
  bool get isFreelance => partnershipType == 'freelance';

  factory Courier.fromJson(Map<String, dynamic> json) {
    return Courier(
      id: json['id'] ?? 0,
      publicId: json['public_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      vehicleType: json['vehicle_type'],
      partnershipType: json['partnership_type'] ?? 'freelance',
      plateNumber: json['plate_number'],
      city: json['city'],
      address: json['address'],
      photoUrl: json['photo_url'],
      payoutMethod: json['payout_method'],
      payoutAccount: json['payout_account'],
      status: json['status'] ?? 'pending',
    );
  }
}
