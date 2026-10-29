import 'package:flutter/material.dart';
import 'package:myapp/app/Settings/Settings.dart';
import 'package:myapp/app/Identification/login.dart';
import 'package:myapp/app/PDVs/list%20de%20pdv.dart';
import 'package:myapp/app/Profile/profile.dart';
import 'package:myapp/app/home/home.dart';
import 'package:myapp/app/services/API_service.dart';

class SideBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final List<String> _menuItems = [
    'Home',
    'PDV',
    'Profile',
    'Settings',
  ];

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Clear any existing user data
      setState(() {
        _userData = null;
      });

      // Fetch fresh data from the server
      final result = await ApiService.fetchUserProfile();
      
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _userData = result['user'];
          _error = null;
        } else {
          _error = result['message'];
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load profile: $e';
      });
      print('Error loading profile: $e'); // Add this for debugging
    }
  }

  Icon _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return const Icon(Icons.home);
      case 1:
        return const Icon(Icons.store);
      case 2:
        return const Icon(Icons.person);
      case 3:
        return const Icon(Icons.settings);
      default:
        return const Icon(Icons.error);
    }
  }

  void _navigateToPage(int index, BuildContext context) {
    widget.onItemSelected(index);
    Navigator.pop(context); // Close the drawer

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PDVListScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsPage(),
            fullscreenDialog: true,
          ),
        );
        break;
    }
  }

  Widget _buildProfileSection() {
    if (_isLoading && _userData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        const CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage('lib/assets/profile_picture.jpg'),
        ),
        const SizedBox(height: 10),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Text(
          _userData?['fullname'] ?? 'Loading...',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_userData != null) ...[
          Text(
            _userData!['email'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            _userData!['phone'] ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Container(
        width: 250,
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildProfileSection(),
            const Divider(),
            
            // Menu items
            Expanded(
              child: ListView.builder(
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: _getIconForIndex(index),
                    title: Text(
                      _menuItems[index],
                      style: TextStyle(
                        color: widget.selectedIndex == index ? Colors.blue : Colors.black,
                      ),
                    ),
                    onTap: () => _navigateToPage(index, context),
                  );
                },
              ),
            ),
            
            // Logout button
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await ApiService.logout();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}