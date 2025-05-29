// lib/models/client.dart
class Client {
  final int id;
  final String name;
  final String phone;
  final String address;
  final double balance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      balance: json['balance'] is double
          ? json['balance']
          : double.parse(json['balance'].toString()),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Getter to calculate days ago
  int get daysAgo {
    final currentDate = DateTime.now();
    return currentDate.difference(updatedAt).inDays;
  }
}
