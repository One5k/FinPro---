// lib/widgets/client_tile.dart

import 'package:flutter/material.dart';

class ClientTile extends StatelessWidget {
  final String name;
  final String amount;
  final Color color;
  final bool isClickable;

  ClientTile({
    required this.name,
    required this.amount,
    required this.color,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.person, color: color),
        title: Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          amount,
          style: TextStyle(fontSize: 16, color: color),
        ),
        trailing: isClickable
            ? Icon(Icons.arrow_forward_ios, color: Colors.grey)
            : null,
      ),
    );
  }
}
