import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const SmartApartApp());
}

class SmartApartApp extends StatefulWidget {
  const SmartApartApp({super.key});

  @override
  State<SmartApartApp> createState() => _SmartApartAppState();
}

class _SmartApartAppState extends State<SmartApartApp> {
  // Temporary — lets us manually flip between light/dark to check the theme.
  // This will be replaced by a proper ThemeProvider in Phase 2.7.
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartApart',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: Scaffold(
        appBar: AppBar(title: const Text('SmartApart')),
        body: Center(
          child: ElevatedButton(
            onPressed: _toggleTheme,
            child: const Text('Toggle theme'),
          ),
        ),
      ),
    );
  }
}