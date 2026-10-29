import 'package:flutter/material.dart';
import 'package:mobilis/model/manager_model.dart';
import 'package:mobilis/database/local_database.dart';
import 'package:mobilis/pages/homepage.dart';
import 'package:mobilis/widgets/app_bar.dart';
import 'package:universal_html/html.dart' as html;


class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();

  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerAddressController = TextEditingController();
  final TextEditingController _registerPhoneController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerConfirmPasswordController = TextEditingController();
  
  final TextEditingController _registerRoleController = TextEditingController(); 
  final TextEditingController _registerWilayaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const CustomAppBar(currentPage: 'auth'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Container(
                    width: 460,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: const Color(0xFF80C24A),
                          unselectedLabelColor: Colors.black45,
                          indicatorColor: const Color(0xFF80C24A),
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'Connexion'),
                            Tab(text: 'Créer un compte'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 500,
                          child: TabBarView(
                            children: [
                              _buildLoginForm(),
                              _buildRegisterForm(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
             
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                Text(
                  'Bienvenue!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Veuillez vous connecter à votre compte pour accéder à toutes les fonctionnalités de notre application. Si vous n\'avez pas encore de compte, vous pouvez en créer un en utilisant l\'onglet "Créer un compte".',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          _buildInput('Email', Icons.email, controller: _loginEmailController, validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre email';
            } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
              return 'Veuillez entrer un email valide';
            }
            return null;
          }),
          _buildInput('Mot de passe', Icons.lock, controller: _loginPasswordController, obscure: true, validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre mot de passe';
            }
            return null;
          }),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
  if (_loginFormKey.currentState?.validate() ?? false) {
  final email = _loginEmailController.text.trim();
  final password = _loginPasswordController.text.trim();

  // Get the user by email from the local storage (the method already exists)
  final user = LocalDatabaseWeb.getUserByEmail(email);

  // If the user doesn't exist or the password is incorrect, show an error
  if (user == null ||user.password != LocalDatabaseWeb.hashPassword(password) ) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email ou mot de passe incorrect')),
    );
    return;
  }

  // If user exists, store their email in window.localStorage
  html.window.localStorage['logged_in_email'] = user.email;


  // Login success — go to home
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SmartZoningHomePage()),
  );
}


   
    
  
},

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80C24A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Se connecter",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildInput('Nom et Prénom', Icons.person, controller: _registerNameController, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre nom et prénom';
              }
              return null;
            }),
            _buildInput('CSM / Agence', Icons.place, controller: _registerAddressController, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre CSM ou bien votre agence';
              }
              return null;
            }),
            _buildInput('Email', Icons.email, controller: _registerEmailController, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            }),
            _buildInput('Numéro de téléphone', Icons.phone, controller: _registerPhoneController, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre numéro de téléphone';
              } else if (!RegExp(r'^(05|06|07)[0-9]{8}$').hasMatch(value)) {
                return 'Numéro invalide';
              }
              return null;
            }),
            _buildInput('Mot de passe', Icons.lock, controller: _registerPasswordController, obscure: true, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un mot de passe';
              }
              return null;
            }),
            _buildInput('Confirmer le mot de passe', Icons.lock, controller: _registerConfirmPasswordController, obscure: true, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez confirmer votre mot de passe';
              } else if (value != _registerPasswordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            }),
            _buildInput('Role', Icons.person, controller: _registerRoleController, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un rôle';
              }
              return null;
            }),
            _buildInput('Wilaya', Icons.location_city, controller: _registerWilayaController, validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer une Wilaya';
              }
              return null;
            }),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
               onPressed: () async {
  if (_registerFormKey.currentState?.validate() ?? false) {
    final newManager = Manager(
      name: _registerNameController.text.trim(),
      email: _registerEmailController.text.trim(),
      agency: _registerAddressController.text.trim(),
      phone: _registerPhoneController.text.trim(),
      password:  LocalDatabaseWeb.hashPassword(_registerPasswordController.text.trim()),
      role: _registerRoleController.text.trim(),
      wilaya: _registerWilayaController.text.trim(),
    );
  
   try {
  LocalDatabaseWeb.addUser(newManager);

  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Compte créé avec succès')),
  );

 // Store logged-in user email in localStorage
   html.window.localStorage['logged_in_email'] = newManager.email;



  // Navigate to home page
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SmartZoningHomePage()),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur lors de l\'inscription: $e')),
  );
}


  }
},

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF80C24A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "S'inscrire",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, {TextEditingController? controller, bool obscure = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20, color: Colors.grey[600]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          validator: validator,
        ),
      ),
    );
  }
}
