import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const OcaiApp());
}

class OcaiApp extends StatelessWidget {
  const OcaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ocai - товары из Китая',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
