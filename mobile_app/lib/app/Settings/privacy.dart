import 'package:flutter/material.dart';
import 'package:myapp/app/Settings/Settings.dart';
import 'package:myapp/app/Settings/privacyoption.dart';

// Privacy Page
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confidentialité'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Padding(
        padding:  EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Paramètres de confidentialité',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 24),
            PrivacyOption(
              title:'Visibilité du profil',
              description:'Choisissez qui peut voir votre profil',
              value:'Public',
            ),
             SizedBox(height: 16),
            PrivacyOption(
              title:'Activité en ligne',
              description:'Afficher votre statut en ligne',
              value:'Activé',
            ),
             SizedBox(height: 16),
            PrivacyOption(
              title:'Historique de recherche',
              description:'Enregistrer votre historique de recherche',
              value:'Désactivé',
            ),
             SizedBox(height: 16),
            PrivacyOption(
              title:'Données de localisation',
              description:'Partager votre position géographique',
              value:'Uniquement pendant l\'utilisation',
            ),
          ],
        ),
      ),
    );
  }

  
}