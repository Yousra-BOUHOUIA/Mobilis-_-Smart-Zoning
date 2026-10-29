import 'package:flutter/material.dart';
import 'package:myapp/app/Identification/InputField.dart';
import 'package:myapp/app/Inscription/LoginLink.dart';
import 'package:myapp/app/Inscription/SignUpButton.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _managerController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _managerController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Inscrire',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'BIENVENUE SUR MOBILIS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'veuillez vous inscrire pour continuer ...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 30),
                          CustomInputField(
                            controller: _nameController,
                            hintText: 'Nom et prénom',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre nom';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomInputField(
                            controller: _emailController,
                            hintText: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre email';
                              }
                              if (!value.endsWith('@mobilis.dz')) {
                                return 'Seuls les emails @mobilis.dz sont acceptés';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomInputField(
                            controller: _phoneController,
                            hintText: 'Numéro de téléphone',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre numéro';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomInputField(
                            controller: _managerController,
                            hintText: 'Manager Responsable',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le nom du manager';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomInputField(
                            controller: _passwordController,
                            hintText: 'Mot de passe',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un mot de passe';
                              }
                              if (value.length < 6) {
                                return '6 caractères minimum';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomInputField(
                            controller: _confirmPasswordController,
                            hintText: 'Confirmer le mot de passe',
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez confirmer le mot de passe';
                              }
                              if (value != _passwordController.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          SignUpButton(
                            formKey: _formKey,
                            nameController: _nameController,
                            emailController: _emailController,
                            phoneController: _phoneController,
                            managerController: _managerController,
                            passwordController: _passwordController,
                          ),
                          const SizedBox(height: 20),
                          const LoginLink(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}