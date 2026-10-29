import 'package:flutter/material.dart';
import 'package:myapp/app/Settings/SecurityOption.dart';
import 'package:myapp/app/Settings/Settings.dart';
// Security Page
class SecurityPage extends StatelessWidget {
   const SecurityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:const  Padding(
        padding:  EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Paramètres de sécurité',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 24),
            SecurityOption(
              title: 'Mot de passe',
              description: 'Modifier votre mot de passe',
              icon: Icons.password_outlined,
            ),
             SizedBox(height: 16),
            SecurityOption(
              title: 'Authentification à deux facteurs',
              description: 'Ajouter une couche de sécurité supplémentaire',
              icon: Icons.phone_android_outlined,
              isEnabled: true,
            ),
             SizedBox(height: 16),
            SecurityOption(
              title: 'Appareils connectés',
              description: 'Gérer les appareils connectés à votre compte',
              icon: Icons.devices_outlined,
            ),
             SizedBox(height: 16),
            SecurityOption(
              title: 'Notifications de connexion',
              description: 'Recevoir des alertes pour les nouvelles connexions',
              icon: Icons.notifications_outlined,
              isEnabled: true,
            ),
          ],
        ),
      ),
    );
  }

 
}
