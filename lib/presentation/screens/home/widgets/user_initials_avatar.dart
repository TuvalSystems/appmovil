import 'package:flutter/material.dart';

class UserInitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color backgroundColor;
  final Color textColor;

  const UserInitialsAvatar({
    super.key,
    required this.name,
    this.radius = 30,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFFEF4B00),
  });

  String getInitials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        getInitials(name),
        style: TextStyle(
          color: textColor,
          fontSize: radius * 0.55,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
