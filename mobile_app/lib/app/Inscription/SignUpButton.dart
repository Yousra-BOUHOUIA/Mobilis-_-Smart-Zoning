// lib/app/Inscription/SignUpButton.dart
import 'package:flutter/material.dart';
import 'package:myapp/app/home/home.dart';
import 'package:myapp/app/services/API_service.dart';

class SignUpButton extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController managerController;
  final TextEditingController passwordController;

  const SignUpButton({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.managerController,
    required this.passwordController,
  }) : super(key: key);

  @override
  State<SignUpButton> createState() => _SignUpButtonState();
}

class _SignUpButtonState extends State<SignUpButton> {
  bool _isLoading = false;

  Future<void> _signUp() async {
  if (!widget.formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final result = await ApiService.signUp(
    fullname: widget.nameController.text.trim(),
    email: widget.emailController.text.trim(),
    phone: widget.phoneController.text.trim(),
    manager: widget.managerController.text.trim(),
    password: widget.passwordController.text,
    context: context,
  );

  setState(() => _isLoading = false);

  if (!mounted) return;

  if (result['success']) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error ${result['statusCode']}: ${result['message']}'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _signUp,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              "s'inscrire",
              style: TextStyle(fontSize: 16),
            ),
    );
  }
}