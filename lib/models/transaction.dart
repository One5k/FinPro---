// lib/models/transaction.dart

class Transaction {
  final int id;
  final int clientId;
  final double amount;
  final String details;
  final DateTime date;
  final String type;
  final String? imagePath;

  Transaction({
    required this.id,
    required this.clientId,
    required this.amount,
    required this.details,
    required this.date,
    required this.type,
    this.imagePath,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      clientId: json['client_id'] is int
          ? json['client_id']
          : int.parse(json['client_id'].toString()),
      amount: json['amount'] is double
          ? json['amount']
          : double.parse(json['amount'].toString()),
      details: json['details'] ?? '',
      date: DateTime.parse(json['date']),
      type: json['type'] ?? '',
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'amount': amount,
      'details': details,
      'date': date.toIso8601String().split('T')[0],
      'type': type,
      'image_path': imagePath,
    };
  }
}
