import 'package:flutter/material.dart';
import 'pages/auth_page.dart';

void main() {
  runApp(const MobilisWebApp());
}

class MobilisWebApp extends StatelessWidget {
  const MobilisWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobilis Web',
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
