import 'package:flutter/material.dart';
import '../pages/homepage.dart';
import '../pages/profile.dart';
import '../pages/assignment_table.dart';
import '../pages/zones_page.dart';
import '../pages/auth_page.dart';

class CustomAppBar extends StatelessWidget {
  final String currentPage;

  const CustomAppBar({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.scale(
            scale: 2,
            child: Image.asset('assets/images/mobilis-logo.png', height: 80),
          ),
          Row(
            children: [
              _navItem(context, 'Accueil', 'home'),
              _navItem(context, 'Zones', 'zones'),
              _navItem(context, 'Affectations', 'affectations'),
              const SizedBox(width: 30),
              _logoutButton(context),
              const SizedBox(width: 15),
              _profileIcon(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String title, String routeKey) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (routeKey == 'home') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SmartZoningHomePage()),
            );
          } else if (routeKey == 'zones') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MapPage()),
            );
          } else if (routeKey == 'affectations') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AssignmentTablePage()),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: currentPage == routeKey ? Colors.lightGreen[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: currentPage == routeKey ? Colors.green : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileIcon(BuildContext context) {
    final bool isActive = currentPage == 'profile';

    return MouseRegion(
      cursor: SystemMouseCursors.click, // Cursor turns to hand on hover
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage()),
          );
        },
        child: Icon(
          Icons.account_circle,
          size: 35,
          color: isActive ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Cursor turns to hand on hover
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'Déconnexion',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
