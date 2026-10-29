import 'package:flutter/material.dart';
import 'package:mobilis/database/local_database.dart';
import 'package:mobilis/pages/edit_profile.dart';
import 'package:mobilis/widgets/app_bar.dart';
import 'package:mobilis/model/manager_model.dart';
import 'package:universal_html/html.dart' as html;
import 'auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final green = const Color(0xFF4CAF50);
  Manager? _manager;

  @override
  void initState() {
    super.initState();
    _loadManager();
  }

  Future<void> _loadManager() async {
    final email = html.window.localStorage['logged_in_email'];
    if (email != null) {
      print("[PROFILE] Email from localStorage: $email");
      final manager = LocalDatabaseWeb.getUserByEmail(email);
      setState(() {
        _manager = manager;
      });
    } else {
      print("[PROFILE] No logged-in email found in localStorage.");
    }
  }

  Future<void> _navigateToEditProfile() async {
    // Wait for the result from EditProfilePage
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
    
    // If we received an updated Manager object
    if (result != null && result is Manager) {
      setState(() {
        _manager = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          CustomAppBar(currentPage: 'profile'),
          Expanded(
            child: Row(
              children: [
                buildSidebar(context),
                Expanded(
                  child: Center(
                    child: Container(
                      height: 500,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        width: 800,
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _manager == null
                              ? const Center(child: CircularProgressIndicator())
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    buildFormRow([
                                      buildDisplayBox("Nom", _manager!.name),
                                      buildDisplayBox("Email", _manager!.email),
                                      buildDisplayBox("Role", _manager!.role),
                                    ]),
                                    const SizedBox(height: 20),
                                    buildFormRow([
                                      buildDisplayBox("Agence/CSM", _manager!.agency),
                                      buildDisplayBox("Téléphone", _manager!.phone),
                                      buildDisplayBox("Wilaya", _manager!.wilaya),
                                    ]),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        border: Border.all(color: green.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Icon(Icons.person_outline, size: 120, color: green.withOpacity(0.7)),
              Positioned(
                bottom: 0,
                right: 12,
                child: GestureDetector(
                  onTap: _navigateToEditProfile,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 14,
                    child: Icon(Icons.edit, size: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Profile",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: green),
            child: const Text("Paramètres", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthPage()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: green),
            child: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildFormRow(List<Widget> fields) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: fields,
    );
  }

  Widget buildDisplayBox(String label, String value) {
    return SizedBox(
      width: 240,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}