import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Singleton
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();
  
  // Propriétés du thème
  bool _isDarkMode = false;
  int _themeColorIndex = 0;
  
  // Getters
  bool get isDarkMode => _isDarkMode;
  int get themeColorIndex => _themeColorIndex;
  
  // Liste des couleurs de thème disponibles
  final List<Color> themeColors = [
    Colors.green,
    Colors.blue,
    Colors.red,
  ];
  
  // Obtenez la couleur actuelle
  Color get currentThemeColor => themeColors[_themeColorIndex];
  
  // Basculer le mode sombre
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  // Changer la couleur du thème
  void setThemeColor(int index) {
    if (index >= 0 && index < themeColors.length) {
      _themeColorIndex = index;
      notifyListeners();
    }
  }
  
  // Obtenir le thème complet
  ThemeData getTheme() {
    return _isDarkMode 
      ? _getDarkTheme(currentThemeColor)
      : _getLightTheme(currentThemeColor);
  }
  
  // Thème clair
  ThemeData _getLightTheme(Color primaryColor) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      primarySwatch: _getMaterialColorFromColor(primaryColor),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Colors.white,
        background: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
    );
  }
  
  // Thème sombre
  ThemeData _getDarkTheme(Color primaryColor) {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      primarySwatch: _getMaterialColorFromColor(primaryColor),
      scaffoldBackgroundColor: Colors.grey[900],
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Colors.grey[850]!,
        background: Colors.grey[900]!,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
  
  // Convertir une couleur en MaterialColor
  MaterialColor _getMaterialColorFromColor(Color color) {
    final int r = color.red;
    final int g = color.green;
    final int b = color.blue;
    
    Map<int, Color> shades = {
      50: Color.fromRGBO(r, g, b, .1),
      100: Color.fromRGBO(r, g, b, .2),
      200: Color.fromRGBO(r, g, b, .3),
      300: Color.fromRGBO(r, g, b, .4),
      400: Color.fromRGBO(r, g, b, .5),
      500: Color.fromRGBO(r, g, b, .6),
      600: Color.fromRGBO(r, g, b, .7),
      700: Color.fromRGBO(r, g, b, .8),
      800: Color.fromRGBO(r, g, b, .9),
      900: Color.fromRGBO(r, g, b, 1),
    };
    
    return MaterialColor(color.value, shades);
  }
}