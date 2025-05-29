// lib/widgets/custom_icon_widget.dart

import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final IconData icon;
  final Color color;

  CustomIconWidget({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
      BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      padding: EdgeInsets.all(16),
      child: Icon(
        icon,
        color: color,
        size: 30,
      ),
    );
  }
}
