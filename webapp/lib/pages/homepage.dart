import 'package:flutter/material.dart';
import 'package:mobilis/widgets/app_bar.dart';
import 'package:mobilis/widgets/footer.dart';
import 'assignment_table.dart';
import 'zones_page.dart'; 
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import '../config.dart';

class SmartZoningHomePage extends StatelessWidget {
  const SmartZoningHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomAppBar(currentPage: 'home'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 150),
                  const Text(
                    'Système De Smart Zoning',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Optimisez la gestion de vos points de vente grâce à la puissance de l’intelligence artificielle\n'
                    'et au Smart Zoning pour une couverture plus intelligente et stratégique.',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),









ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    textStyle: const TextStyle(fontSize: 24),
  ),
  onPressed: () async {
    // 1) Pick a CSV file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.single.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun fichier sélectionné.'))
      );
      return;
    }

    final bytes = result.files.single.bytes!;
    final name = result.files.single.name;
    print("Picked CSV: $name, size=${bytes.length}");

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Traitement en cours..."),
              SizedBox(height: 10),
              Text("Étape 1: Chargement du fichier", style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      }
    );

    // 2) Prepare multipart request
    var dio = Dio();
    // Add timeouts to handle network issues
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    dio.options.sendTimeout = const Duration(seconds: 60);
    
    FormData formData = FormData.fromMap({
      "file": MultipartFile.fromBytes(bytes, filename: name),
      "n_clusters": "5",
      "enable_detailed_logging": "true", // Request detailed processing logs
    });

    try {
      // 3) Use the endpoint from config
      final endpoint = BackendConfig.uploadCsvEndpoint;
      print("Sending upload request to: $endpoint");

      // Update processing dialog
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Envoi et traitement en cours..."),
                SizedBox(height: 10),
                Text("Étape 2: Prétraitement des données", style: TextStyle(fontSize: 12)),
                Text("- Nettoyage des données", style: TextStyle(fontSize: 12)),
                Text("- Suppression des coordonnées invalides", style: TextStyle(fontSize: 12)),
                Text("- Filtrage des PDVs hors zone", style: TextStyle(fontSize: 12)),
              ],
            ),
          );
        }
      );

      // Log the request before sending
      print("Sending formData: ${formData.fields}");
      
      final resp = await dio.post(
        endpoint, 
        data: formData,
        onSendProgress: (sent, total) {
          print("Upload progress: ${(sent / total * 100).toStringAsFixed(2)}%");
        },
      );
      
      print("Response statusCode: ${resp.statusCode}");
      print("Response data: ${resp.data}");

      // Close processing dialog
      Navigator.pop(context);

      if (resp.statusCode == 200) {
        // Display detailed results
        Map<String, dynamic> data = resp.data;
        
        // Extract processing statistics
        int originalPoints = data['original_point_count'] ?? 0;
        int validPoints = data['valid_point_count'] ?? 0;
        int removedPoints = originalPoints - validPoints;
        
        // Get detailed statistics if available
        Map<String, dynamic> detailedStats = data['detailed_stats'] ?? {};
        int nanDropped = detailedStats['nan_dropped'] ?? 0;
        int invalidCoords = detailedStats['invalid_coords'] ?? 0;
        int invalidRange = detailedStats['invalid_range'] ?? 0;
        int outsideBoundary = detailedStats['outside_boundary'] ?? 0;
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Prétraitement complété"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Points originaux: $originalPoints", 
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Points valides: $validPoints", 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    Text("Points supprimés: $removedPoints", 
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    const Divider(),
                    if (detailedStats.isNotEmpty) ...[
                      const Text("Détails des suppressions:", 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("- Valeurs manquantes: $nanDropped"),
                      Text("- Coordonnées invalides: $invalidCoords"),
                      Text("- Coordonnées hors plage: $invalidRange"),
                      Text("- Points hors wilaya: $outsideBoundary"),
                    ],
                    const SizedBox(height: 10),
                    if (removedPoints == 0)
                      const Text(
                        "Attention: Aucun point n'a été supprimé durant le prétraitement. "
                        "Vérifiez que votre fichier contient des coordonnées correctes et "
                        "qu'il correspond bien à la wilaya indiquée.",
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 10),
                    const Text("Les clusters ont été générés avec succès!", 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Fermer"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MapPage()),
                    );
                  },
                  child: const Text("Voir sur la carte"),
                ),
              ],
            );
          }
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${resp.statusCode}'))
        );
      }
    } catch (e) {
      // Close processing dialog if still showing
      Navigator.of(context, rootNavigator: true).pop();
      
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi: $e'))
      );
    }
  },
  child: const Text(
    'Télécharger un fichier CSV',
    style: TextStyle(fontSize: 24, color: Colors.white),
  ),
),





















                  const SizedBox(height: 150),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/zoning.png',
                                width: 400,
                                height: 400,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Génération de Smart Zoning',
                              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(
                              width: 500,
                              child: Text(
                                'Obtenez des zones intelligentes de PDVs basées sur la distance et le nombre de PDVs.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                textStyle: const TextStyle(fontSize: 18),
                                side: const BorderSide(width: 1),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MapPage()),
                                );
                              },
                              child: const Text('Générer le Zoning'),
                            ),
                          ],
                        ),
                        const SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/mini_map.png',
                                width: 400,
                                height: 400,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Affectation des Représentants',
                              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(
                              width: 500,
                              child: Text(
                                'Assignez des représentants et couvrez les zones de manière plus optimisée.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                                textStyle: const TextStyle(fontSize: 18),
                                side: const BorderSide(width: 1),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AssignmentTablePage()),
                                );
                              },
                              child: const Text('Voir le Tableau des Affectations'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const CustomFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
