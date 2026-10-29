import 'package:flutter/material.dart';
import 'package:mobilis/widgets/app_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

import '../config.dart'; // Change to match your project structure
import 'package:dio/dio.dart'; // Make sure you're using Dio for consistency

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool showInput = false;
  final TextEditingController _repCountController = TextEditingController();
  final bool _isLoading = false;
  String _statusMessage = '';
  
  // Map data
  Map<String, dynamic> _clusterData = {};
  bool _isMapDataLoading = true;
  List<Marker> _markers = [];
  List<Polygon> _clusterPolygons = [];
  
  // Colors for different clusters
  final List<Color> _clusterColors = [
    Colors.red.withOpacity(0.3),
    Colors.blue.withOpacity(0.3),
    Colors.green.withOpacity(0.3),
    Colors.purple.withOpacity(0.3),
    Colors.orange.withOpacity(0.3),
    Colors.teal.withOpacity(0.3),
    Colors.indigo.withOpacity(0.3),
    Colors.amber.withOpacity(0.3),
    Colors.cyan.withOpacity(0.3),
    Colors.pink.withOpacity(0.3),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Start animation when entering page
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        showInput = true;
        _controller.forward();
      });
    });
    
    // Load cluster data
    _loadClusterData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _repCountController.dispose();
    super.dispose();
  }
  
  // Load cluster data from the JSON file
  Future<void> _loadClusterData() async {
  setState(() {
    _isMapDataLoading = true;
  });
  
  try {
    // Use your backend endpoint to get the clustering data
    final clustersEndpoint = BackendConfig.clustersEndpoint;  // <-- Use the correct endpoint
    
    print('Fetching cluster data from: $clustersEndpoint');
    
    final response = await http.get(Uri.parse(clustersEndpoint));
    
    if (response.statusCode == 200) {
      setState(() {
        _clusterData = json.decode(response.body);
        _processClusterData();
        _isMapDataLoading = false;
      });
    } else {
      setState(() {
        _statusMessage = 'Failed to load cluster data: ${response.statusCode}';
        _isMapDataLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _statusMessage = 'Error loading cluster data: $e';
      _isMapDataLoading = false;
    });
  }
}
  // Process the cluster data to create polygons and markers
  void _processClusterData() {
    _markers = [];
    _clusterPolygons = [];
    
    print('Processing cluster data: ${_clusterData.length} clusters');
    
    // Process each cluster
    _clusterData.forEach((clusterId, points) {
      if (points is List && points.isNotEmpty) {
        // Extract points for this cluster
        List<LatLng> clusterPoints = [];
        
        // Track min/max lat/lng to calculate convex hull points
        double minLat = double.infinity;
        double maxLat = -double.infinity;
        double minLng = double.infinity;
        double maxLng = -double.infinity;
        
        // Process each point in the cluster
        for (var point in points) {
          if (point is Map<String, dynamic>) {
            // Get the latitude and longitude from the point
            double? lat;
            double? lng;
            
            // Handle different possible field names
            if (point.containsKey('Latitude') && point.containsKey('Longitude')) {
              // Try parsing as double directly
              final latValue = point['Latitude'];
              final lngValue = point['Longitude'];
              
              if (latValue is double) {
                lat = latValue;
              } else if (latValue is String) {
                lat = double.tryParse(latValue);
              } else if (latValue is int) {
                lat = latValue.toDouble();
              }
              
              if (lngValue is double) {
                lng = lngValue;
              } else if (lngValue is String) {
                lng = double.tryParse(lngValue);
              } else if (lngValue is int) {
                lng = lngValue.toDouble();
              }
            } else if (point.containsKey('latitude') && point.containsKey('longitude')) {
              // Check for lowercase keys
              final latValue = point['latitude'];
              final lngValue = point['longitude'];
              
              if (latValue is double) {
                lat = latValue;
              } else if (latValue is String) {
                lat = double.tryParse(latValue);
              } else if (latValue is int) {
                lat = latValue.toDouble();
              }
              
              if (lngValue is double) {
                lng = lngValue;
              } else if (lngValue is String) {
                lng = double.tryParse(lngValue);
              } else if (lngValue is int) {
                lng = lngValue.toDouble();
              }
            }
            
            // If we have valid coordinates, add them to the cluster points
            if (lat != null && lng != null) {
              // Update min/max values
              minLat = min(minLat, lat);
              maxLat = max(maxLat, lat);
              minLng = min(minLng, lng);
              maxLng = max(maxLng, lng);
              
              // Add point to cluster points
              clusterPoints.add(LatLng(lat, lng));
              
              // Add a marker for some points (not all to avoid cluttering)
              if (_markers.length < 30 && Random().nextInt(3) == 0) {
                _markers.add(
                                    Marker(
                      width: 12,
                      height: 12,
                      point: LatLng(lat, lng),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getClusterColor(clusterId),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    )
                );
              }
            }
          }
        }
        
        // If we have points, create a polygon for this cluster
        if (clusterPoints.isNotEmpty) {
          // Create a simple convex hull approximation
          final convexHull = _approximateConvexHull(clusterPoints);
          
          _clusterPolygons.add(
            Polygon(
              points: convexHull,
              color: _getClusterColor(clusterId),
              borderColor: _getClusterColor(clusterId).withOpacity(0.7),
              borderStrokeWidth: 3.0,
              isFilled: true,
            ),
          );
        }
      }
    });
    
    setState(() {});
  }
  
  // Get a color for a specific cluster ID
  Color _getClusterColor(String clusterId) {
    // Extract the cluster number from the ID (assuming format like "cluster_0")
    final clusterNumber = int.tryParse(clusterId.split('_').last) ?? 0;
    return _clusterColors[clusterNumber % _clusterColors.length];
  }
  
  // Create a simple convex hull approximation
  List<LatLng> _approximateConvexHull(List<LatLng> points) {
    if (points.length <= 3) return points;
    
    // Find center of all points
    double centerLat = 0;
    double centerLng = 0;
    
    for (var point in points) {
      centerLat += point.latitude;
      centerLng += point.longitude;
    }
    
    centerLat /= points.length;
    centerLng /= points.length;
    
    // Sort points by angle from center
    final center = LatLng(centerLat, centerLng);
    points.sort((a, b) {
      final angleA = atan2(a.latitude - center.latitude, a.longitude - center.longitude);
      final angleB = atan2(b.latitude - center.latitude, b.longitude - center.longitude);
      return angleA.compareTo(angleB);
    });
    
    // For a more accurate "wrapping" of points, take all the points and sort them by angle
    final sortedPoints = List<LatLng>.from(points);
    // Add the first point at the end to close the loop
    sortedPoints.add(sortedPoints.first);
    
    // For web performance, if we have too many points, downsample
    final hullPoints = <LatLng>[];
    final step = max(1, (sortedPoints.length / 15).round()); // Adjust for web performance
    
    for (int i = 0; i < sortedPoints.length; i += step) {
      if (i < sortedPoints.length) {
        hullPoints.add(sortedPoints[i]);
      }
    }
    
    // Make sure we close the polygon by adding the first point if needed
    if (hullPoints.isNotEmpty && hullPoints.last != hullPoints.first) {
      hullPoints.add(hullPoints.first);
    }
    
    return hullPoints;
  }

 void _showDialog(BuildContext context, bool isAdd, Offset position) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 20.0, right: 20.0),
        child: Container(
          width: 380,
          height: 370,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
            ],
          ),
          child: PDVDialog(isAdd: isAdd),
        ),
      ),
    ),
  ).then((value) {
    // If operation was successful (value is true), reload the map data
    if (value == true) {
      _loadClusterData();
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const CustomAppBar(currentPage: 'zones'),
          SizeTransition(
            sizeFactor: _animation,
            axisAlignment: -1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: _repCountController,
                    keyboardType: TextInputType.number,
                    onSubmitted: (value) async {
                      int? reps = int.tryParse(value);
                      if (reps != null) {
                        print('Nombre des représentants: $reps');
                        
                        try {
                          // Use the endpoint from config
                          final endpoint = BackendConfig.rerunClusteringEndpoint;
                          print('Sending rerun request to: $endpoint');
                          
                          // Use Dio instead of multiple http attempts
                          var dio = Dio();
                          FormData formData = FormData.fromMap({
                            "n_clusters": reps.toString(),
                          });
                          
                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Re-clustering en cours...'))
                          );
                          
                          final response = await dio.post(endpoint, data: formData);
                          print('Response: ${response.statusCode}');
                          print('Response data: ${response.data}');
                          
                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Re-clustering réussi avec $reps clusters')),
                            );
                            // Reload cluster data
                            _loadClusterData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: ${response.statusCode}')),
                            );
                          }
                        } catch (e) {
                          print('Error during re-clustering: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur de connexion: $e')),
                          );
                        }
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Entrer le nombre des représentants',
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Text(_statusMessage),
                        ],
                      ),
                    )
                  else if (_statusMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_statusMessage),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                _isMapDataLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : FlutterMap(
                      options: MapOptions(
                        center: LatLng(36.75, 3.05), // Algiers
                        zoom: 12.0,
                        // Add interactive features
                        interactiveFlags: InteractiveFlag.all,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: const ['a', 'b', 'c'],
                          // Optimize for web
                          tileProvider: NetworkTileProvider(),
                          maxZoom: 19,
                        ),
                        // Add cluster polygons
                        PolygonLayer(
                          polygons: _clusterPolygons,
                        ),
                        // Add markers for some PDVs
                        MarkerLayer(
                          markers: _markers,
                        ),
                      ],
                    ),
                Positioned(
                  top: 20,
                  left: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: 'add',
                        onPressed: () {
                          final renderBox = context.findRenderObject() as RenderBox;
                          final position = renderBox.localToGlobal(const Offset(10, 30));
                          _showDialog(context, true, position);
                        },
                        backgroundColor: Colors.green,
                        mini: true,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'remove',
                        onPressed: () {
                          final renderBox = context.findRenderObject() as RenderBox;
                          final position = renderBox.localToGlobal(const Offset(10, 70));
                          _showDialog(context, false, position);
                        },
                        backgroundColor: Colors.red[200],
                        mini: true,
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: 'refresh',
                        onPressed: _loadClusterData,
                        backgroundColor: Colors.blue[200],
                        mini: true,
                        child: const Icon(Icons.refresh, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                // Legend for clusters
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Clusters',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        ..._clusterData.keys.map((clusterId) {
                          final clusterNumber = clusterId.split('_').last;
                          // Count how many points in this cluster
                          final pointCount = (_clusterData[clusterId] as List).length;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getClusterColor(clusterId),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text('Cluster $clusterNumber ($pointCount PDVs)'),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                
                // Status indicator for web app
                if (_isMapDataLoading)
                  Positioned(
                    top: 20,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Chargement des zones...'),
                        ],
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
}

class PDVDialog extends StatefulWidget {
  final bool isAdd;
  const PDVDialog({super.key, required this.isAdd});

  @override
  _PDVDialogState createState() => _PDVDialogState();
}
class _PDVDialogState extends State<PDVDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController communeController = TextEditingController();
  final TextEditingController dairaController = TextEditingController();
  final TextEditingController wilayaController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController pdvIdController = TextEditingController(); // For deletion
  
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    nameController.dispose();
    communeController.dispose();
    dairaController.dispose();
    wilayaController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    pdvIdController.dispose();
    super.dispose();
  }

  Future<void> _handleAction(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (widget.isAdd) {
        await _addPDV(context);
      } else {
        await _deletePDV(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addPDV(BuildContext context) async {
    // Form validation
    if (nameController.text.isEmpty ||
        communeController.text.isEmpty ||
        wilayaController.text.isEmpty ||
        latitudeController.text.isEmpty ||
        longitudeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all required fields';
      });
      return;
    }

    final name = nameController.text;
    final commune = communeController.text;
    final daira = dairaController.text;
    final wilaya = wilayaController.text;
    final latitude = double.tryParse(latitudeController.text);
    final longitude = double.tryParse(longitudeController.text);

    if (latitude == null || longitude == null) {
      setState(() {
        _errorMessage = 'Invalid latitude or longitude values';
      });
      return;
    }

    try {
      // Use Dio for consistent API calls
      var dio = Dio();
      
      // Use the endpoint from config
      final endpoint = BackendConfig.assignPdvEndpoint;
      
      // Prepare data according to your backend API
      final pdvData = {
        'pdv': {
          'name': name,
          'commune': commune,
          'daira': daira,
          'wilaya': wilaya,
          'latitude': latitude,
          'longitude': longitude,
        },
        'wilaya_boundaries': {}, // Add boundaries if needed by your API
        'threshold': 5.0 // Default threshold as in your backend
      };
      
      // Make the API call
      final response = await dio.post(
        endpoint,
        data: pdvData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDV added successfully'))
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
      });
      rethrow;
    }
  }

  Future<void> _deletePDV(BuildContext context) async {
    // For deletion based on coordinates
    double? latitude;
    double? longitude;
    
    // Check if we're using coordinates for deletion
    if (latitudeController.text.isNotEmpty && longitudeController.text.isNotEmpty) {
      latitude = double.tryParse(latitudeController.text);
      longitude = double.tryParse(longitudeController.text);
      
      if (latitude == null || longitude == null) {
        setState(() {
          _errorMessage = 'Invalid latitude or longitude values';
        });
        return;
      }
    } else {
      setState(() {
        _errorMessage = 'Please provide latitude and longitude for deletion';
      });
      return;
    }

    try {
      // Use Dio for consistent API calls
      var dio = Dio();
      
      // Use the endpoint from config
      final endpoint = BackendConfig.deletePdvEndpoint;
      
      // Prepare data according to your backend API
      final deleteData = {
        'latitude': latitude,
        'longitude': longitude
      };
      
      // Make the API call
      final response = await dio.post(
        endpoint,
        data: deleteData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDV deleted successfully'))
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error: $e';
      });
      rethrow;
    }
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              widget.isAdd ? 'Ajouter un PDV' : 'Supprimer un PDV',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          if (widget.isAdd) ...[
            // Form fields for adding a PDV
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(controller: nameController, decoration: _fieldDecoration('Nom de PDV')),
                      const SizedBox(height: 12),
                      TextField(controller: dairaController, decoration: _fieldDecoration('Daira')),
                      const SizedBox(height: 12),
                      TextField(controller: latitudeController, decoration: _fieldDecoration('Latitude*')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      TextField(controller: communeController, decoration: _fieldDecoration('Commune')),
                      const SizedBox(height: 12),
                      TextField(controller: wilayaController, decoration: _fieldDecoration('Wilaya')),
                      const SizedBox(height: 12),
                      TextField(controller: longitudeController, decoration: _fieldDecoration('Longitude*')),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            // Form fields for deleting a PDV - just need coordinates
            Column(
              children: [
                const Text(
                  'Entrez les coordonnées du PDV à supprimer',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(controller: latitudeController, decoration: _fieldDecoration('Latitude*')),
                const SizedBox(height: 12),
                TextField(controller: longitudeController, decoration: _fieldDecoration('Longitude*')),
              ],
            ),
          ],
          
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
            ),
            
          const SizedBox(height: 24),
          
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isAdd ? Colors.green[300] : Colors.red[300],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _isLoading ? null : () => _handleAction(context),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.isAdd ? 'Ajouter' : 'Supprimer',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
          
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}