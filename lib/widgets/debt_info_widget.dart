// lib/widgets/debt_info_widget.dart

import 'package:flutter/material.dart';

class DebtInfoWidget extends StatelessWidget {
  final String givenAmount;
  final String takenAmount;

  DebtInfoWidget({
    required this.givenAmount,
    required this.takenAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                "المبالغ التي أعطيتها",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                givenAmount,
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                "المبالغ التي أخذتها",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                takenAmount,
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
