import 'package:flutter/material.dart';
import 'package:myapp/app/Identification/login.dart';

class LoginLink extends StatelessWidget {
  const LoginLink({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'vous avez déjà un compte ?',
          style: TextStyle(color: Colors.white70),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>const  LoginScreen()),
            );
          },
          child: const Text(
            'Connexion',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}