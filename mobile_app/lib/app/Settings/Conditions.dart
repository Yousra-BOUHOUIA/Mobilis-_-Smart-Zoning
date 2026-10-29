import 'package:flutter/material.dart';
import 'package:myapp/app/Settings/TermsSection.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conditions d\'utilisation'),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Conditions Générales d\'Utilisation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Dernière mise à jour : 3 mai 2025',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 24),
          const TermsSection(
            title:'1. Acceptation des conditions', 
            content:'En utilisant cette application, vous acceptez d\'être lié par les présentes Conditions d\'Utilisation. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.'
          ),
          const TermsSection(
            title:'2. Utilisation de l\'application',
            content:'L\'application est fournie "telle quelle" et "selon disponibilité". Nous ne garantissons pas que l\'application sera ininterrompue, opportune, sécurisée ou sans erreur.'
          ),
          const TermsSection(
            title:'3. Compte utilisateur',
            content:'Vous êtes responsable du maintien de la confidentialité de votre compte et mot de passe. Vous acceptez d\'assumer la responsabilité de toutes les activités qui se produisent sous votre compte.'
          ),
          const TermsSection(
            title:'4. Limitation de responsabilité',
            content:'En aucun cas, nous ne serons responsables de tout dommage direct, indirect, accessoire, spécial ou consécutif résultant de l\'utilisation ou de l\'impossibilité d\'utiliser l\'application.'
          ),
          const TermsSection(
            title:'5. Modification des conditions',
            content:'Nous nous réservons le droit de modifier ou remplacer ces conditions à tout moment. Il est de votre responsabilité de vérifier périodiquement les modifications.'
          ),
          const TermsSection(
            title:'6. Résiliation',
            content:'Nous pouvons résilier ou suspendre votre accès immédiatement, sans préavis ni responsabilité, pour quelque raison que ce soit, y compris, sans limitation, si vous enfreignez les Conditions.'
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: const Text('J\'accepte les conditions'),
          ),
        ],
      ),
    );
  }

}