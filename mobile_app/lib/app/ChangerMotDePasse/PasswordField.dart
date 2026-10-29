import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? Function(String?)? validator;
  final Color fieldColor;

  const PasswordField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.validator,
    this.fieldColor = const Color(0xFF2DB34B),
  }) : super(key: key);

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !_isVisible,
      validator: widget.validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.fieldColor.withOpacity(0.1),
        labelText: widget.label,
        hintText: widget.hintText,
        labelStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isVisible = !_isVisible;
            });
          },
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
          borderSide: BorderSide(color: widget.fieldColor),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}