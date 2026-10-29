import 'dart:convert';
import 'package:http/http.dart' as http;

class PDVService {
  static const String baseUrl = 'http://192.168.18.68:8000'; // Update with your FastAPI server URL

  Future<void> _generatePath() async {
    try {
      // Execute the optimal path generation script
      final response = await http.post(
        Uri.parse('$baseUrl/execute-optimal-path'),
        headers: {'Content-Type': 'application/json'},
      );
      print('POST execute-optimal-path response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to execute optimal path generation. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error in _generatePath: $e');
      throw Exception('Error executing optimal path generation: $e');
    }
  }

  Future<Map<String, dynamic>> getOptimalPath() async {
    try {
      // First try to get the path
      var response = await http.get(Uri.parse('$baseUrl/optimal-path'));
      print('GET optimal-path response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Debug log
      
      // If path doesn't exist, generate it
      if (response.statusCode != 200) {
        print('Path not found, executing optimal path generation...');
        await _generatePath();
        // Try getting the path again after generation
        response = await http.get(Uri.parse('$baseUrl/Optimal_path'));
        print('Second attempt response body: ${response.body}'); // Debug log
      }
      
      if (response.statusCode != 200) {
        throw Exception('Failed to get optimal path. Status: ${response.statusCode}, Body: ${response.body}');
      }
      
      final Map<String, dynamic> data = json.decode(response.body);
      print('Decoded data: $data'); // Debug log
      
      // The path data might be directly in the response or nested
      if (data.containsKey('Optimal_path')) {
        return data;
      } else if (data.containsKey('path')) {
        return {'Optimal_path': data['path']};
      } else {
        // If the data is directly the path array
        return {'Optimal_path': data};
      }
    } catch (e) {
      print('Error in getOptimalPath: $e');
      throw Exception('Error with optimal path: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPDVs() async {
    try {
      // First ensure we have a valid path
      await getOptimalPath();
      
      // Then get PDVs
      final response = await http.get(Uri.parse('$baseUrl/pdvs'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data.entries.map((entry) {
          final pdv = entry.value as Map<String, dynamic>;
          return {
            'id': entry.key,
            'name': 'PDV ${entry.key.substring(3)}',
            'location': '${pdv['commune']}/${pdv['daira']}/${pdv['wilaya']}',
            'scanned': pdv['status'] ?? false,
            'coordinates': pdv['coordinates'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load PDVs');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }

  Future<void> updatePDVStatus(String pdvId, bool status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-pdv-status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'pdv_id': pdvId,
          'status': status,
        }),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update PDV status');
      }
    } catch (e) {
      throw Exception('Error updating PDV status: $e');
    }
  }

  Future<void> generatePath() async {
    await _generatePath();
  }

  Future<void> saveStat({
    required String userId,
    required String date,
    required int scannedCount,
    required int totalCount,
    required double percent,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/save-stat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'date': date,
        'scanned_count': scannedCount,
        'total_count': totalCount,
        'percent': percent,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to save stat: \\${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getStats(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/get-stats?user_id=$userId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch stats: \\${response.body}');
    }
  }
} 