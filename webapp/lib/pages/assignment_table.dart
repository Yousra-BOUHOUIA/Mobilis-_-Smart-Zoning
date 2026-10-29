import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobilis/model/pdv_model.dart';
import 'package:mobilis/model/representative_model.dart';
import 'package:mobilis/widgets/app_bar.dart';
import 'package:mobilis/widgets/footer.dart';

import '../config.dart'; // Import BackendConfig

class AssignmentTablePage extends StatefulWidget {
  const AssignmentTablePage({super.key});

  @override
  State<AssignmentTablePage> createState() => _AssignmentTablePageState();
}

class _AssignmentTablePageState extends State<AssignmentTablePage> {
  Map<int, List<PDV>> clusterPDVs = {};
  List<Representative> representatives = [];
  bool isLoading = true;
  
  // Track assigned representatives to each zone
  final Map<int, Representative> assignedRepresentatives = {};
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load cluster data using the clusters endpoint
      await _loadClusterData();
      
      // Load representative data
      // For now we'll use mock data, but this should be replaced with an API call
      await _loadRepresentatives();
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur lors du chargement des données: $e';
      });
      print('Error loading data: $e');
    }
  }
  
  Future<void> _loadClusterData() async {
    try {
      // Use the clusters endpoint from BackendConfig
      final clustersEndpoint = BackendConfig.clustersEndpoint;
      
      print('Fetching cluster data from: $clustersEndpoint');
      
      final response = await http.get(Uri.parse(clustersEndpoint));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final Map<int, List<PDV>> clusters = {};
        
        // Process the cluster data
        jsonData.forEach((clusterId, points) {
          if (points is List) {
            // Extract cluster number from the clusterId (format: "cluster_X")
            final clusterNumber = int.tryParse(clusterId.split('_').last) ?? 0;
            
            // Convert each point to a PDV object
            final List<PDV> pdvList = [];
            
            for (var point in points) {
              if (point is Map<String, dynamic>) {
                try {
                  pdvList.add(PDV.fromJson(point));
                } catch (e) {
                  print('Error converting point to PDV: $e');
                  // If conversion fails, create a PDV with available data
                  final pdv = PDV(
                    name: point['Name'] ?? point['name'] ?? 'Unknown',
                    commune: point['Commune'] ?? point['commune'] ?? '',
                    daira: point['Daira'] ?? point['daira'] ?? '',
                    wilaya: point['Wilaya'] ?? point['wilaya'] ?? '',
                    latitude: _extractDouble(point, 'Latitude', 'latitude'),
                    longitude: _extractDouble(point, 'Longitude', 'longitude'),
                  );
                  pdvList.add(pdv);
                }
              }
            }
            
            // Add cluster to the map
            clusters[clusterNumber] = pdvList;
          }
        });
        
        setState(() {
          clusterPDVs = clusters;
        });
        
        print('Loaded ${clusters.length} clusters with data');
      } else {
        setState(() {
          errorMessage = 'Failed to load cluster data: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('Error loading cluster data: $e');
      setState(() {
        errorMessage = 'Error loading cluster data: $e';
      });
    }
  }
  
  // Helper function to extract double values from various field names
  double _extractDouble(Map<String, dynamic> data, String upperCaseKey, String lowerCaseKey) {
    var value;
    
    if (data.containsKey(upperCaseKey)) {
      value = data[upperCaseKey];
    } else if (data.containsKey(lowerCaseKey)) {
      value = data[lowerCaseKey];
    }
    
    if (value is double) {
      return value;
    } else if (value is int) {
      return value.toDouble();
    } else if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    
    return 0.0;
  }
  
  // This is a placeholder for loading representatives
  // In a real implementation, this should be replaced with an API call
  Future<void> _loadRepresentatives() async {
  try {
    final String jsonData = await DefaultAssetBundle.of(context).loadString('assets/representatives.json');
    
    // Parse the outer Map
    final Map<String, dynamic> jsonMap = json.decode(jsonData);
    
    // Access the "representatives" list
    final List<dynamic> jsonList = jsonMap['representatives'];
    
    // Map each item to a Representative object
    final List<Representative> loadedRepresentatives = jsonList
        .map((json) => Representative.fromJson(json))
        .toList();

    setState(() {
      representatives = loadedRepresentatives;
    });

    print('Successfully loaded ${representatives.length} representatives from JSON file');
  } catch (e) {
    print('Error loading representatives from JSON file: $e');
    setState(() {
      errorMessage = 'Error loading representatives: $e';
      representatives = [];
    });
  }
}

  int? selectedZone;
  final Map<int, Set<int>> selectedPDVs = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _toggleSelection(int zoneIndex, int pdvIndex) {
    setState(() {
      final selected = selectedPDVs.putIfAbsent(zoneIndex, () => <int>{});
      if (selected.contains(pdvIndex)) {
        selected.remove(pdvIndex);
      } else {
        selected.add(pdvIndex);
      }
    });
  }

  void _showSearchPanel(BuildContext context, int zoneIndex) {
    _searchController.clear();
    _searchQuery = '';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: SizedBox(
            width: 400,
            height: 450,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  child: Text(
                    'Assigner un représentant pour Zone ${zoneIndex.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher par email ou nom...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value.trim().toLowerCase());
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Résultats :", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: _sortedAndFilteredRepresentatives(_searchQuery, zoneIndex)
                        .map((rep) => _representativeResultTile(context, rep, zoneIndex))
                        .toList(),
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (assignedRepresentatives.containsKey(zoneIndex))
                        TextButton(
                          onPressed: () {
                            setState(() {
                              assignedRepresentatives.remove(zoneIndex);
                            });
                            Navigator.of(context).pop();
                            // Update the parent state to reflect the change
                            this.setState(() {});
                          },
                          child: const Text('Effacer l\'affectation', 
                            style: TextStyle(color: Colors.red)),
                        ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Representative> _sortedAndFilteredRepresentatives(String query, int zoneIndex) {
    // Filter representatives based on search query
    List<Representative> filteredReps = representatives.where((rep) => 
      rep.name.toLowerCase().contains(query.toLowerCase()) || 
      rep.email.toLowerCase().contains(query.toLowerCase())
    ).toList();
    
    // Sort representatives - currently assigned representative for this zone comes first
    filteredReps.sort((a, b) {
      // Check if either rep is the one assigned to this zone
      final currentlyAssigned = assignedRepresentatives[zoneIndex];
      if (currentlyAssigned != null) {
        if (a.email == currentlyAssigned.email) return -1;
        if (b.email == currentlyAssigned.email) return 1;
      }
      return a.name.compareTo(b.name); // Otherwise sort alphabetically
    });
    
    return filteredReps;
  }

 Widget _representativeResultTile(BuildContext context, Representative rep, int zoneIndex)
 {
    final isCurrentlyAssigned = assignedRepresentatives[zoneIndex]?.email == rep.email;
    
    return InkWell(
      onTap: () {
        setState(() {
          assignedRepresentatives[zoneIndex] = rep;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isCurrentlyAssigned ? Colors.blue[50] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isCurrentlyAssigned ? Colors.blue : Colors.grey),
        ),
        child: Row(
          children: [
            Icon(Icons.person_outline, 
                color: isCurrentlyAssigned ? Colors.blue : null),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rep.name, 
                      style: TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.bold,
                        color: isCurrentlyAssigned ? Colors.blue[800] : null
                      )),
                  Text(rep.email, 
                      style: TextStyle(
                        fontSize: 13, 
                        color: isCurrentlyAssigned ? Colors.blue[600] : Colors.grey
                      )),
                ],
              ),
            ),
            if (isCurrentlyAssigned)
              const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  void _showPDVList(BuildContext context, int zoneIndex, {bool selectable = false}) {
    // Adjust for zero-based indexing, API clusters start from 0
    final pdvs = clusterPDVs[zoneIndex - 1];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: SizedBox(
            width: 400,
            height: 500,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  child: Text(
                    selectable
                        ? 'Spécifier les PDVs pour Zone ${zoneIndex.toString().padLeft(2, '0')}'
                        : 'Liste des PDVs pour Zone ${zoneIndex.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (pdvs == null || pdvs.isEmpty)
                  const Expanded(
                    child: Center(child: Text('Aucun PDV disponible pour cette zone.')),
                  )
                else
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: pdvs.length,
                        itemBuilder: (context, i) {
                          final pdv = pdvs[i];
                          final isSelected = selectedPDVs[zoneIndex]?.contains(i) ?? false;

                          return ListTile(
                            onTap: selectable
                                ? () => setState(() => _toggleSelection(zoneIndex, i))
                                : null,
                            leading: selectable
                                ? Checkbox(
                                    value: isSelected,
                                    onChanged: (_) => setState(() => _toggleSelection(zoneIndex, i)),
                                  )
                                : const Icon(Icons.store),
                            title: Text(pdv.name),
                            subtitle: Text('${pdv.commune}, ${pdv.daira}, ${pdv.wilaya}'),
                            tileColor: i % 2 == 0 ? Colors.grey[100] : null,
                          );
                        },
                      ),
                    ),
                  ),
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (selectable)
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Confirmer'),
                        ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _zoneButton(int index) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          textStyle: const TextStyle(fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: () => _showPDVList(context, index),
        child: Text('Zone ${index.toString().padLeft(2, '0')}'),
      ),
    );
  }

  Widget _assignerButton(int index) {
    final rep = assignedRepresentatives[index];
    
    return Center(
      child: MouseRegion(
        onEnter: (_) => setState(() => selectedZone = index),
        onExit: (_) => setState(() => selectedZone = null),
        child: GestureDetector(
          onTap: () => _showSearchPanel(context, index),
          child: rep != null 
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[100],
                  ),
                  child: Column(
                    children: [
                      Text(rep.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(rep.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        'Modifier',
                        style: TextStyle(
                          color: selectedZone == index ? Colors.green : Colors.blue,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                )
              : AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    color: selectedZone == index ? Colors.green : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                  child: const Text('Attribuer'),
                ),
        ),
      ),
    );
  }

  Widget _specifyPDVButton(int index) {
    final selectedCount = selectedPDVs[index]?.length ?? 0;
    
    return Center(
      child: ElevatedButton(
        onPressed: () => _showPDVList(context, index, selectable: true),
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedCount > 0 ? Colors.blue[100] : Colors.grey[200],
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          selectedCount > 0
              ? "$selectedCount PDVs sélectionnés"
              : "Spécifier les PDVs"
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                errorMessage!,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _loadData();
                },
                child: Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    
    // Determine the number of zones from the loaded clusters
    final int zoneCount = clusterPDVs.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomAppBar(currentPage: 'affectations'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Affectations par Zone',
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadData,
                        tooltip: 'Actualiser les données',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                    },
                    border: TableBorder.all(color: Colors.grey),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Colors.black12),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(
                              child: Text(
                                'Les Zones',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(
                              child: Text(
                                'Les Représentants',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(
                              child: Text(
                                'Sélectionner des PDVs',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...List.generate(zoneCount, (index) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: _zoneButton(index + 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: _assignerButton(index + 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: _specifyPDVButton(index + 1),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 100),
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