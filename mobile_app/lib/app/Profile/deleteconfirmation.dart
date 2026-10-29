import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:myapp/app/Identification/login.dart';
import 'package:myapp/app/services/API_service.dart';

class DeleteAccountDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer définitivement votre compte ? Cette action ne peut pas être annulée.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                final result = await ApiService.deleteAccount();
                
                if (result['success']) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Votre compte a été supprimé avec succès.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Failed to delete account'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}