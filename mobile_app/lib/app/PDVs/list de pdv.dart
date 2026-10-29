import 'package:flutter/material.dart';
import 'package:myapp/app/PDVs/QRCode.dart';
import 'package:myapp/app/PDVs/pdv_map_view.dart';
import 'package:myapp/app/Profile/profile.dart';
import 'package:myapp/app/home/home.dart';
import 'package:myapp/app/services/pdv_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PDVListScreen extends StatefulWidget {
  const PDVListScreen({Key? key}) : super(key: key);

  @override
  State<PDVListScreen> createState() => _PDVListScreenState();
}

class _PDVListScreenState extends State<PDVListScreen> {
  int _selectedIndex = 1;
  List<Map<String, dynamic>> pdvList = [];
  bool _isLoading = true;
  final PDVService _pdvService = PDVService();
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPdvData();
  }

  Future<void> _loadPdvData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get all PDVs first
      final allPdvs = await _pdvService.getPDVs();

      // Compute a hash of the PDV list
      final pdvHash = base64Encode(utf8.encode(jsonEncode(allPdvs)));

      final prefs = await SharedPreferences.getInstance();
      final lastPdvHash = prefs.getString('pdv_hash');

      // If the PDV list has changed, trigger optimal path calculation
      if (lastPdvHash != pdvHash) {
        await _pdvService.generatePath(); // Trigger recalculation
        await prefs.setString('pdv_hash', pdvHash);
        await prefs.remove('scanned_statuses');
      }

      // Now get the optimal path (it will be up-to-date)
      final optimalPath = await _pdvService.getOptimalPath();

      // Load scanned statuses from local storage
      Map<String, bool> scannedStatuses = {};
      final scannedJson = prefs.getString('scanned_statuses');
      if (scannedJson != null) {
        scannedStatuses = Map<String, bool>.from(jsonDecode(scannedJson));
      }

      // --- Robust path extraction (as before) ---
      dynamic pathData = optimalPath['Optimal_path'] ?? optimalPath['optimal_path'];
      if (pathData == null) throw Exception('No path data found in response');
      if (pathData is Map && pathData.containsKey('optimal_path')) pathData = pathData['optimal_path'];
      if (pathData is! List) throw Exception('Path data is not a List: \\${pathData.runtimeType}');

      // Create a map of PDVs by ID for easy lookup
      final pdvMap = {for (var pdv in allPdvs) pdv['id']: pdv};

      final orderedPdvs = pathData.map<Map<String, dynamic>>((pdv) {
        final pdvId = pdv['key'] ?? pdv['id'] ?? pdv.toString();
        final pdvData = pdvMap[pdvId];
        final scanned = scannedStatuses[pdvId] ?? pdvData?['scanned'] ?? false;
        if (pdvData == null) {
          return {
            'id': pdvId,
            'name': 'PDV $pdvId',
            'location': 'Unknown Location',
            'scanned': scanned,
            'visit_order': pdv['visit_order'] ?? pdv['order'] ?? 0,
          };
        }
        return {
          ...pdvData,
          'scanned': scanned,
          'visit_order': pdv['visit_order'] ?? pdv['order'] ?? 0,
        };
      }).toList();

      setState(() {
        pdvList = orderedPdvs;
        _isLoading = false;
      });

      // Save the current list to local storage (optional)
      await prefs.setString('pdv_list', jsonEncode(pdvList));
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _callHomeSaveTodayStat(BuildContext context) async {
    // Find the HomePage state and call _saveTodayStat if possible
    final homeState = context.findAncestorStateOfType<HomePageState>();
    if (homeState != null) {
      await homeState.saveTodayStat();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading PDVs',
                style: TextStyle(color: Colors.red),
              ),
              Text(_error!),
              ElevatedButton(
                onPressed: _loadPdvData,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('List de PDV'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPdvData,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pdvList.length,
        itemBuilder: (context, index) {
          final item = pdvList[index];
          return _buildPdvListItem(item, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDVMapView(pdvList: pdvList),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.map),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.blue,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: ' ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: ' ',
          ),
        ],
      ),
    );
  }

  Widget _buildPdvListItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Center(
              child: item['scanned'] 
                  ? const Icon(Icons.check, color: Colors.green, size: 24)
                  : Text(
                      '${item['visit_order']}',
                      style: const TextStyle(color: Colors.black54),
                    ),
            ),
          ),
        ),
        title: Text(
          item['name']!,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.green,
          ),
        ),
        subtitle: Text(
          item['location']!,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: item['scanned']
            ? null // No trailing widget if already scanned
            : GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QRScannerScreen()),
                  );
                  
                  if (result != null && result is bool && result) {
                    setState(() {
                      pdvList[index]['scanned'] = true;
                    });
                    // Save the updated scanned statuses
                    final prefs = await SharedPreferences.getInstance();
                    Map<String, bool> scannedStatuses = {};
                    final scannedJson = prefs.getString('scanned_statuses');
                    if (scannedJson != null) {
                      scannedStatuses = Map<String, bool>.from(jsonDecode(scannedJson));
                    }
                    scannedStatuses[pdvList[index]['id']] = true;
                    await prefs.setString('scanned_statuses', jsonEncode(scannedStatuses));

                    // --- Update backend stats and refresh chart ---
                    final homeState = context.findAncestorStateOfType<HomePageState>();
                    if (homeState != null) {
                      await homeState.saveTodayStat();
                    }
                  }
                },
                child: Container(
                  width: 100,
                  height: 100,
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.black,
                    size: 37,
                  ),
                ),
              ),
      ),
    );
  }
}