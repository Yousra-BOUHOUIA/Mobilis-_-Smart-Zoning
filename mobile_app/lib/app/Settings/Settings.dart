import 'package:flutter/material.dart';
import 'package:myapp/app/Profile/deleteAccount.dart';
import 'package:myapp/app/Profile/profile.dart';
import 'package:myapp/app/Settings/AboutApp.dart';
import 'package:myapp/app/Settings/Conditions.dart';
import 'package:myapp/app/Settings/Mode.dart';
import 'package:myapp/app/Settings/SectionHeader.dart';
import 'package:myapp/app/Settings/SettingsItem.dart';
import 'package:myapp/app/Settings/help&Support.dart';
import 'package:myapp/app/Settings/privacy.dart';
import 'package:myapp/app/Settings/security.dart';
import 'package:myapp/app/Settings/theme.dart';
import 'package:myapp/app/Home/home.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            const SectionHeader(title:'Compte'),
            SettingItem(
              icon: Icons.person_outline,
              title: 'Profil',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            SettingItem(
              icon: Icons.delete_outline,
              title: 'Supprimer le compte',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DeleteAccountPage()),
                );
              },
            ),
            const Divider(height: 40),
            const SectionHeader(title:'Confidentialité et sécurité'),
            SettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Confidentialité',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPage()),
                );
              },
            ),
            SettingItem(
              icon: Icons.security_outlined,
              title: 'Sécurité',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecurityPage()),
                );
              },
            ),
            const Divider(height: 40),
            const SectionHeader(title:'Préférences'),
            SettingItem(
              icon: Icons.notifications_none,
              title: 'Notifications',
              onTap: () {},
            ),
            SettingItem(
              icon: Icons.dark_mode_outlined,
              title: 'Mode sombre',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DarkModePage()),
                );
              },
            ),
            SettingItem(
              icon: Icons.format_paint_outlined,
              title: 'Thème',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThemePage()),
                );
              },
            ),
            const Divider(height: 40),
            const SectionHeader(title:'Support'),
            SettingItem(
              icon: Icons.help_outline,
              title: 'Aide & Support',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpSupportPage()),
                );
              },
            ),
            SettingItem(
              icon: Icons.info_outline,
              title: 'À propos de l\'application',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutAppPage()),
                );
              },
            ),
            SettingItem(
              icon: Icons.policy_outlined,
              title: 'Conditions d\'utilisation',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
                );
              },
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
















