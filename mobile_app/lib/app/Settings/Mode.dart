import 'package:flutter/material.dart';
import 'package:myapp/app/Settings/SettingsItem.dart';
import 'package:myapp/app/Settings/themeProvider.dart';

class DarkModePage extends StatefulWidget {
  const DarkModePage({Key? key}) : super(key: key);

  @override
  State<DarkModePage> createState() => _DarkModePageState();
}

class _DarkModePageState extends State<DarkModePage> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(() {
      setState(() {}); // Update the switch when theme changes
    });
  }

  @override
  void dispose() {
    _themeProvider.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Sombre'),
        elevation: 1,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          SettingItem(
            icon: Icons.dark_mode_outlined,
            title: 'Activer le mode sombre',
            trailing: Switch(
              value: _themeProvider.isDarkMode,
              activeColor: Colors.green,
              onChanged: (value) {
                _themeProvider.toggleDarkMode();
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Le mode sombre réduit la luminosité de l\'écran...',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
