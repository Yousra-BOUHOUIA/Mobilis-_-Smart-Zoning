import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType keyboardType;
  final Color fieldColor;

  const InputField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.keyboardType,
    this.fieldColor = const Color(0xFF2DB34B),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: fieldColor.withOpacity(0.1),
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: fieldColor),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}