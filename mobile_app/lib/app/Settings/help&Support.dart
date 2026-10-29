import 'package:flutter/material.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  // Map pour stocker l'état d'expansion de chaque question
  final Map<String, bool> _expandedQuestions = {};
  
  // Liste des questions et réponses
  final List<Map<String, String>> _faqItems = [
    {
      'question': 'Comment modifier mon profil ?',
      'answer': 'Accédez à votre profil en cliquant sur l\'icône de profil dans le menu principal. Ensuite, appuyez sur le bouton "Modifier" pour changer vos informations personnelles, votre photo de profil ou vos préférences.'
    },
    {
      'question': 'Comment réinitialiser mon mot de passe ?',
      'answer': 'Sur la page de profil, cliquez sur "Changer le mot de passe" et suivez les instructions pour modifier votre mot de passe actuel. Si vous êtes déjà connecté, vous pourrez directement le modifier sans confirmation par e-mail.'
    },
    {
      'question': 'Comment contacter le service client ?',
      'answer': 'Vous pouvez contacter notre service client par e-mail à support@monapp.com, par téléphone au +33 1 23 45 67 89, ou en utilisant la fonction de chat en direct disponible dans l\'application de 9h à 18h en semaine.'
    },
    {
      'question': 'Comment supprimer mon compte ?',
      'answer': 'Pour supprimer votre compte, accédez à la page Paramètres depuis votre profil, puis sélectionnez "Gérer mon compte" et enfin "Supprimer mon compte". Vous devrez confirmer cette action qui est irréversible.'
    },
    {
      'question': 'L\'application ne fonctionne pas correctement, que faire ?',
      'answer': 'Essayez d\'abord de redémarrer l\'application. Si le problème persiste, vérifiez que vous utilisez la dernière version disponible. Vous pouvez également vider le cache de l\'application dans les paramètres de votre téléphone ou nous contacter directement pour obtenir de l\'aide.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
        elevation: 1,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          
          // Section FAQ
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Questions fréquentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          
          // FAQ Items
          ..._faqItems.map((item) => _buildExpandableFaqItem(item)),
          
          const Divider(height: 30),
          
          // Section Contact
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Contactez-nous',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          
          // Contact Items
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email'),
            subtitle: const Text('support@monapp.com'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: const Text('Téléphone'),
            subtitle: const Text('+33 1 23 45 67 89'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.chat_outlined),
            title: const Text('Chat en direct'),
            subtitle: const Text('Disponible de 9h à 18h'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableFaqItem(Map<String, String> item) {
    final String question = item['question']!;
    final String answer = item['answer']!;
    
    // Initialiser l'état d'expansion s'il n'existe pas encore
    _expandedQuestions.putIfAbsent(question, () => false);
    final bool isExpanded = _expandedQuestions[question]!;
    
    return Column(
      children: [
        ListTile(
          title: Text(question),
          trailing: TextButton(
            child: Text(
              isExpanded ? 'Masquer' : 'Afficher',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onPressed: () {
              setState(() {
                _expandedQuestions[question] = !isExpanded;
              });
            },
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(answer),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}