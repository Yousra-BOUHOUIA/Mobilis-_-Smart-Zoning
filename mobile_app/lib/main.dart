import 'package:flutter/material.dart';
import 'package:myapp/app/Acceuil/acceuil.dart';
import 'package:myapp/app/Identification/login.dart';
import 'package:myapp/app/Inscription/sign_up.dart';
import 'package:myapp/app/PDVs/list%20de%20pdv.dart';
import 'package:myapp/app/Profile/profile.dart';
import 'package:myapp/app/Settings/Settings.dart';
import 'package:myapp/app/Settings/themeProvider.dart';
import 'package:myapp/app/home/home.dart';
import 'package:myapp/app/Settings/delete_account.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeProvider _themeProvider = ThemeProvider();
  
  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() {
      setState(() {});
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobilis App',
      theme: _themeProvider.getTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(), 
        '/settings': (context) => const SettingsPage(), 
        '/profile': (context) => const ProfileScreen(),
        '/pdv': (context) => const PDVListScreen(),
        '/delete-account': (context) => const DeleteAccountPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}