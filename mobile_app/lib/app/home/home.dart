import 'package:flutter/material.dart';
import 'package:myapp/app/PDVs/list%20de%20pdv.dart';
import 'package:myapp/app/Profile/profile.dart';
import 'package:myapp/app/home/LineChartPainter.dart';
import 'package:myapp/app/home/side%20bar.dart';
import 'package:myapp/app/services/pdv_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/app/Settings/themeProvider.dart';
import 'dart:convert';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> lastPdvs = [];
  bool _isLoadingPdvs = true;
  String? _pdvError;
  final PDVService _pdvService = PDVService();

  // For statistics
  List<Map<String, dynamic>> stats = [];
  bool _isLoadingStats = true;
  String? _statsError;
  String userId = 'user1'; // TODO: Replace with real user id from auth

  @override
  void initState() {
    super.initState();
    _fetchLastPdvs();
    _fetchStats();
  }

  Future<void> _fetchLastPdvs() async {
    try {
      setState(() {
        _isLoadingPdvs = true;
        _pdvError = null;
      });
      final pdvs = await _pdvService.getPDVs();
      // Get the last 3 PDVs (assuming the last in the list are the most recently added)
      final lastThree = pdvs.length >= 3 ? pdvs.sublist(pdvs.length - 3) : pdvs;
      setState(() {
        lastPdvs = lastThree.reversed.toList(); // Show newest first
        _isLoadingPdvs = false;
      });
    } catch (e) {
      setState(() {
        _pdvError = e.toString();
        _isLoadingPdvs = false;
      });
    }
  }

  Future<void> _fetchStats() async {
    try {
      setState(() {
        _isLoadingStats = true;
        _statsError = null;
      });
      final fetchedStats = await _pdvService.getStats(userId);
      setState(() {
        stats = fetchedStats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _statsError = e.toString();
        _isLoadingStats = false;
      });
    }
  }

  Future<void> saveTodayStat() async {
    try {
      final pdvs = await _pdvService.getPDVs();
      final prefs = await SharedPreferences.getInstance();
      final scannedJson = prefs.getString('scanned_statuses');
      Map<String, bool> scannedStatuses = {};
      if (scannedJson != null) {
        scannedStatuses = Map<String, bool>.from(jsonDecode(scannedJson));
      }
      int scannedCount = pdvs.where((pdv) => scannedStatuses[pdv['id']] == true).length;
      int totalCount = pdvs.length;
      double percent = totalCount > 0 ? (scannedCount / totalCount) * 100 : 0;
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _pdvService.saveStat(
        userId: userId,
        date: today,
        scannedCount: scannedCount,
        totalCount: totalCount,
        percent: percent,
      );
      await _fetchStats();
    } catch (e) {
      // Optionally handle error
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PDVListScreen()), 
        );
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
    final themeProvider = ThemeProvider();
    final themeColor = themeProvider.currentThemeColor;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        title: const Text(
          'Accueil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: SideBar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            Navigator.of(context).pop(); // Close drawer
            _onItemTapped(index);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        'lib/assets/city_skyline.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistiques du Performance:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoadingStats
                      ? const Center(child: CircularProgressIndicator())
                      : _statsError != null
                          ? Text('Erreur: $_statsError', style: const TextStyle(color: Colors.red))
                          : stats.isEmpty
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: 120,
                                      width: double.infinity,
                                      child: CustomPaint(
                                        painter: LineChartPainter(),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Aucun travail effectué pour l'instant.",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  height: 120,
                                  width: double.infinity,
                                  child: CustomPaint(
                                    painter: LineChartPainter(),
                                  ),
                                ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tâches ajoutées:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isLoadingPdvs
                        ? const Center(child: CircularProgressIndicator())
                        : _pdvError != null
                            ? Text('Erreur: \\$_pdvError', style: const TextStyle(color: Colors.red))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: lastPdvs.isEmpty
                                    ? [const Text('Aucun PDV ajouté récemment.')]
                                    : lastPdvs.map((pdv) => Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pdv['name'] ?? 'Nom inconnu',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color.fromARGB(221, 89, 172, 73),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                pdv['location'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )).toList(),
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            label: " ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: " ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            label: " ",
          ),
        ],
      ),
    );
  }
}


