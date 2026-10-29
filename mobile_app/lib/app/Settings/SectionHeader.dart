import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final double fontSize;
  final EdgeInsets padding;

  const SectionHeader({
    Key? key,
    required this.title,
    this.color = Colors.green,
    this.fontSize = 18.0,
    this.padding = const EdgeInsets.only(bottom: 8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}