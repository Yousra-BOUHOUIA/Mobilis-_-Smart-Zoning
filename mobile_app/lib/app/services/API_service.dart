// lib/app/services/API_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL for your FastAPI backend
  static String get baseUrl {
    // For Android devices, use the PC's IP address
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://192.168.18.68:8000';  // Your PC's actual IP address
    }
    // For iOS simulator
    if (!kIsWeb && Platform.isIOS) {
      return 'http://localhost:8000';
    }
    // For web or desktop
    return 'http://localhost:8000';
  }

  // Key constants for SharedPreferences
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _tokenKey = 'auth_token';

  // Helper method to handle network errors
  static String _handleNetworkError(dynamic error) {
    if (error is SocketException) {
      return 'Cannot connect to the server. Please check your internet connection and make sure the server is running.';
    } else if (error is HttpException) {
      return 'Could not find the requested resource on the server.';
    } else if (error is FormatException) {
      return 'Invalid response from the server.';
    }
    return 'An unexpected error occurred: $error';
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save auth token
  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear auth token
  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Logout method
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_tokenKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Get logged in user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userDataKey);
    if (userData != null) {
      return jsonDecode(userData) as Map<String, dynamic>;
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<Map<String, dynamic>> signUp({
    required String fullname,
    required String email,
    required String phone,
    required String manager,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'phone': phone,
          'manager': manager,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 201) {
        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, jsonEncode(responseData['user']));
        await prefs.setBool(_isLoggedInKey, true);
        
        return {
          'success': true, 
          'message': responseData['message'].toString(), 
          'user': responseData['user'],
        };
      } else {
        return {
          'success': false, 
          'message': (responseData['detail'] ?? 'Registration failed').toString(),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': _handleNetworkError(e),
        'statusCode': 500,
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        // Save auth token
        final token = responseData['access_token'] as String;
        await saveAuthToken(token);
        
        // Get user data from the response
        final userData = responseData['user'] ?? responseData;
        
        // Save user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, jsonEncode(userData));
        await prefs.setBool(_isLoggedInKey, true);
        
        return {
          'success': true, 
          'message': 'Login successful', 
          'user': userData,
        };
      } else {
        return {
          'success': false, 
          'message': responseData['detail'] ?? 'Login failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Login error: $e'); // Add this for debugging
      return {
        'success': false, 
        'message': _handleNetworkError(e),
        'statusCode': 500,
      };
    }
  }

  static Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'statusCode': 401,
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final userData = responseData['user'] as Map<String, dynamic>;
        
        // Update stored user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, jsonEncode(userData));
        
        return {
          'success': true,
          'user': userData,
        };
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        print('Profile fetch error: ${response.body}'); // Add this for debugging
        return {
          'success': false,
          'message': errorData['detail'] ?? 'Failed to fetch profile',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Profile fetch error: $e'); // Add this for debugging
      return {
        'success': false,
        'message': _handleNetworkError(e),
        'statusCode': 500,
      };
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String fullname,
    required String email,
    required String phone,
    required String manager,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'statusCode': 401,
        };
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'phone': phone,
          'manager': manager,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        // Update stored user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, jsonEncode(responseData['user']));
        
        return {
          'success': true,
          'message': 'Profile updated successfully',
          'user': responseData['user'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Failed to update profile',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleNetworkError(e),
        'statusCode': 500,
      };
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'statusCode': 401,
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/users/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Failed to change password',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleNetworkError(e),
        'statusCode': 500,
      };
    }
  }

  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final token = await getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'statusCode': 401,
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/users/delete-account'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        // Clear local data
        await logout();
        
        return {
          'success': true,
          'message': 'Account deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['detail'] ?? 'Failed to delete account',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': _handleNetworkError(e),
        'statusCode': 500,
      };
    }
  }
}