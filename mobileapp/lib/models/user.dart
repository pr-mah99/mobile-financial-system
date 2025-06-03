
// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final double walletBalance;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.walletBalance,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      walletBalance: double.parse(json['wallet_balance'].toString()),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'wallet_balance': walletBalance,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}