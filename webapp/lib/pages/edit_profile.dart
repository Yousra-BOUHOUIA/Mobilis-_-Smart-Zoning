import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:mobilis/model/manager_model.dart';
import 'package:mobilis/database/local_database.dart';
import 'package:mobilis/widgets/app_bar.dart';
import 'package:mobilis/pages/auth_page.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Color green = const Color(0xFF4CAF50);
  final _formKey = GlobalKey<FormState>();
  bool _showPasswordSection = false;

  Manager? _manager;
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'email': TextEditingController(),
    'role': TextEditingController(),
    'agency': TextEditingController(),
    'phone': TextEditingController(),
    'wilaya': TextEditingController(),
    'currentPassword': TextEditingController(),
    'newPassword': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadManager();
  }

  Future<void> _loadManager() async {
    final email = html.window.localStorage['logged_in_email'];
    if (email != null) {
      final manager = LocalDatabaseWeb.getUserByEmail(email);
      if (manager != null) {
        setState(() {
          _manager = manager;
          _controllers['name']!.text = manager.name;
          _controllers['email']!.text = manager.email;
          _controllers['role']!.text = manager.role;
          _controllers['agency']!.text = manager.agency;
          _controllers['phone']!.text = manager.phone;
          _controllers['wilaya']!.text = manager.wilaya;
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate() && _manager != null) {
      // First, update basic profile information
      final updated = Manager(
        name: _controllers['name']!.text,
        email: _controllers['email']!.text,
        role: _controllers['role']!.text,
        agency: _controllers['agency']!.text,
        phone: _controllers['phone']!.text,
        wilaya: _controllers['wilaya']!.text,
        password: _manager!.password, // Keep existing password initially
      );
      
      // Update basic profile information
      LocalDatabaseWeb.updateUser(updated);
      
      // Update password if the user chose to change it
      if (_showPasswordSection && _controllers['newPassword']!.text.isNotEmpty) {
        final passwordUpdateResult = LocalDatabaseWeb.updateUserPassword(
          updated.email,
          _controllers['currentPassword']!.text,
          _controllers['newPassword']!.text
        );
        
        if (passwordUpdateResult == 'SUCCESS') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil et mot de passe mis à jour avec succès')),
          );
        } else if (passwordUpdateResult == 'INVALID_CURRENT') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mot de passe actuel incorrect. Profil mis à jour mais mot de passe inchangé.'),
              backgroundColor: Colors.orange,
            ),
          );
          // Return updated data to the previous screen with the original password
          Navigator.pop(context, updated);
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la mise à jour du mot de passe. Profil mis à jour mais mot de passe inchangé.'),
              backgroundColor: Colors.red,
            ),
          );
          // Return updated data to the previous screen with the original password
          Navigator.pop(context, updated);
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
      }
      
      // Return updated data to the previous screen
      Navigator.pop(context, updated);
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
                    child: SingleChildScrollView(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
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
                                : Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        buildFormRow([
                                          buildInputField("Nom", 'name'),
                                          buildInputField("Email", 'email'),
                                          buildInputField("Role", 'role'),
                                        ]),
                                        const SizedBox(height: 20),
                                        buildFormRow([
                                          buildInputField("Agence/CSM", 'agency'),
                                          buildInputField("Téléphone", 'phone'),
                                          buildInputField("Wilaya", 'wilaya'),
                                        ]),
                                        const SizedBox(height: 30),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              value: _showPasswordSection,
                                              onChanged: (value) {
                                                setState(() {
                                                  _showPasswordSection = value ?? false;
                                                  
                                                  // Clear password fields when toggling
                                                  if (!_showPasswordSection) {
                                                    _controllers['currentPassword']!.clear();
                                                    _controllers['newPassword']!.clear();
                                                    _controllers['confirmPassword']!.clear();
                                                  }
                                                });
                                              },
                                              activeColor: green,
                                            ),
                                            const Text("Modifier le mot de passe"),
                                          ],
                                        ),
                                        if (_showPasswordSection) ...[
                                          const SizedBox(height: 20),
                                          buildFormRow([
                                            buildInputField("Mot de passe actuel", 'currentPassword', isPassword: true),
                                            buildInputField("Nouveau mot de passe", 'newPassword', isPassword: true),
                                            buildInputField("Confirmer mot de passe", 'confirmPassword', isPassword: true, confirmPassword: true),
                                          ]),
                                        ],
                                        const SizedBox(height: 30),
                                        ElevatedButton(
                                          onPressed: _saveChanges,
                                          style: ElevatedButton.styleFrom(backgroundColor: green),
                                          child: const Text("Enregistrer", style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
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
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 14,
                  child: Icon(Icons.edit, size: 16, color: Colors.green),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Modification du Profil",
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

  Widget buildInputField(String label, String key, {bool isPassword = false, bool confirmPassword = false}) {
    return SizedBox(
      width: 240,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          controller: _controllers[key],
          obscureText: isPassword,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          validator: (value) {
            if (!isPassword) {
              return value == null || value.isEmpty ? 'Champ requis' : null;
            }
            
            // Password validation is only required if the password section is shown
            if (_showPasswordSection) {
              if (key == 'currentPassword' && (value == null || value.isEmpty)) {
                return 'Mot de passe actuel requis';
              }
              
              if (key == 'newPassword') {
                if (value == null || value.isEmpty) {
                  return null; // New password is optional
                } else if (value.length < 6) {
                  return 'Le mot de passe doit contenir au moins 6 caractères';
                }
              }
              
              if (key == 'confirmPassword' && _controllers['newPassword']!.text.isNotEmpty) {
                if (value == null || value.isEmpty) {
                  return 'Confirmation requise';
                } else if (value != _controllers['newPassword']!.text) {
                  return 'Les mots de passe ne correspondent pas';
                }
              }
            }
            
            return null;
          },
        ),
      ),
    );
  }
}