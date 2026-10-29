import 'package:flutter/material.dart';
import 'package:myapp/app/Profile/InfoRow.dart';
import 'package:myapp/app/Profile/MenuItem.dart';
import 'package:myapp/app/ChangerMotDePasse/change%20pass.dart';
import 'package:myapp/app/Identification/login.dart';
import 'package:myapp/app/Profile/modify_profile.dart';
import 'package:myapp/app/PDVs/list%20de%20pdv.dart';
import 'package:myapp/app/home/home.dart';
import 'package:myapp/app/services/API_service.dart';
import 'package:myapp/app/Profile/deleteconfirmation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await ApiService.fetchUserProfile();
      setState(() {
        _userData = result['success'] ? result['user'] : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userData = null;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PDVListScreen()), 
        );
        break;
      case 2:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('Failed to load profile'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage('lib/assets/profile_picture.jpg'),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _userData!['fullname'] ?? 'No Name',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _userData!['email'] ?? 'No Email',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 30),
                      
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            InfoRow(
                              label: 'Nom et Prénom',
                              value: _userData!['fullname'] ?? 'No Name',
                            ),
                            const Divider(),
                            InfoRow(
                              label: 'Email',
                              value: _userData!['email'] ?? 'No Email',
                            ),
                            const Divider(),
                            InfoRow(
                              label: 'Phone',
                              value: _userData!['phone'] ?? 'No Phone',
                            ),
                            const Divider(),
                            InfoRow(
                              label: 'Manager Responsable',
                              value: _userData!['manager'] ?? 'No Manager',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            MenuItem(
                              icon: Icons.edit,
                              text: 'Editer le profil',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const ProfileEditPage()),
                              ),
                            ),
                            MenuItem(
                              icon: Icons.lock_outline,
                              text: 'Changer le mot de passe',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const PasswordChangePage()),
                              ),
                            ),
                            MenuItem(
                              icon: Icons.delete_outline,
                              text: 'Supprimer le compte',
                              onTap: () => DeleteAccountDialog.show(context),
                              textColor: Colors.red,
                            ),
                            MenuItem(
                              icon: Icons.logout,
                              text: 'Déconnexion',
                              onTap: () async {
                                await ApiService.logout();
                                if (mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const LoginScreen()),
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.blue,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: ' ',
          ),
        ],
      ),
    );
  }
}