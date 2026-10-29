import 'package:flutter/material.dart';
import 'package:myapp/app/Settings/SettingsItem.dart';
import 'package:myapp/app/Settings/themeProvider.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({Key? key}) : super(key: key);

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
        elevation: 1,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          SettingItem(
            icon: Icons.color_lens,
            title: 'Theme Color',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildColorOption(0, Colors.green),
                const SizedBox(width: 8),
                _buildColorOption(1, Colors.blue),
                const SizedBox(width: 8),
                _buildColorOption(2, Colors.red),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Choose your preferred theme color',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(int index, Color color) {
    final isSelected = _themeProvider.themeColorIndex == index;
    return GestureDetector(
      onTap: () => _themeProvider.setThemeColor(index),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF2E7D32), // Dark green
    scaffoldBackgroundColor: const Color(0xFFF1F8E9), // Light green background
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF2E7D32), // Dark green
      secondary: const Color(0xFF4CAF50), // Medium green
      surface: const Color(0xFFE8F5E9), // Very light green
      background: const Color(0xFFF1F8E9), // Light green background
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E7D32), // Dark green
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50), // Medium green
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF2E7D32), // Dark green
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFFE8F5E9), // Very light green
      elevation: 2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFE8F5E9), // Very light green
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4CAF50)), // Medium green
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF2E7D32)), // Dark green
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4CAF50), // Medium green
      secondary: Color(0xFF2E7D32), // Dark green
      surface: Color(0xFF121212), // Dark surface
      background: Colors.black,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50), // Medium green
        foregroundColor: Colors.white,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF121212), // Dark surface
      elevation: 2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF121212), // Dark surface
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4CAF50)), // Medium green
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4CAF50)), // Medium green
      ),
      labelStyle: const TextStyle(color: Colors.white),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
  );
} 